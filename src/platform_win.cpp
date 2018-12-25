////////////////////////////////////////////////////////////////////////////////
// This file contains Windows implementation of platform-dependent functions

#include "src/common.h"
#include "src/usbdevice.h"

#include <QApplication>
#include <QTime>
#include <QDebug>

// Several WinAPI COM specific macros for keeping the code clean

// Runs the COM request specified, checks for return value and throws an exception
// with descriptive error message if it's not OK
#define CHECK_OK(code, msg)                             \
{                                                   \
    HRESULT res = code;                             \
    if (res != S_OK)                                \
{                                               \
    throw formatErrorMessageFromCode(msg, res); \
    }                                               \
    }

// Releases the COM object and nullifies the pointer
#define SAFE_RELEASE(obj)   \
{                       \
    if (obj != nullptr)    \
{                   \
    obj->Release(); \
    obj = nullptr;     \
    }                   \
    }

// Allocated a BSTR string using the specified text, checks for successful memory allocation
// and throws an exception with descriptive error message if unsuccessful
#define ALLOC_BSTR(name, str)                                                 \
{                                                                         \
    name = SysAllocString(str);                                           \
    if (name == nullptr)                                                     \
{                                                                     \
    throw QObject::tr("Memory allocation for %1 failed.").arg(#name); \
    }                                                                     \
    }

// Releases the BSTR string and nullifies the pointer
#define FREE_BSTR(str)      \
{                       \
    SysFreeString(str); \
    str = nullptr;         \
    }

void delay( int millisecondsToWait )
{
    QTime dieTime = QTime::currentTime().addMSecs( millisecondsToWait );
    while( QTime::currentTime() < dieTime )
    {
        QCoreApplication::processEvents( QEventLoop::AllEvents, 100 );
    }
}

QList<UsbDevice> platformEnumFlashDevices()
{
    // Using WMI for enumerating the USB devices

    // Namespace of the WMI classes
    BSTR strNamespace       = nullptr;
    // "WQL" - the query language we're gonna use (the only possible, actually)
    BSTR strQL              = nullptr;
    // Query string for requesting physical devices
    BSTR strQueryDisks      = nullptr;
    // Query string for requesting partitions for each of the the physical devices
    BSTR strQueryPartitions = nullptr;
    // Query string for requesting logical disks for each of the partitions
    BSTR strQueryLetters    = nullptr;

    // Various COM objects for executing the queries, enumerating lists and retrieving properties
    IWbemLocator*         pIWbemLocator         = nullptr;
    IWbemServices*        pWbemServices         = nullptr;
    IEnumWbemClassObject* pEnumDisksObject      = nullptr;
    IEnumWbemClassObject* pEnumPartitionsObject = nullptr;
    IEnumWbemClassObject* pEnumLettersObject    = nullptr;
    IWbemClassObject*     pDiskObject           = nullptr;
    IWbemClassObject*     pPartitionObject      = nullptr;
    IWbemClassObject*     pLetterObject         = nullptr;

    // Temporary object for attaching data to the combobox entries
    UsbDevice* deviceData;
    QList<UsbDevice> l;
    bool loop;
    try
    {
        // Start with allocating the fixed strings
        ALLOC_BSTR(strNamespace, L"root\\cimv2");
        ALLOC_BSTR(strQL, L"WQL");
        ALLOC_BSTR(strQueryDisks, L"SELECT * FROM Win32_DiskDrive WHERE InterfaceType = \"USB\"");

        // Create the IWbemLocator and execute the first query (list of physical disks attached via USB)
        CHECK_OK(CoCreateInstance(CLSID_WbemAdministrativeLocator, nullptr, CLSCTX_INPROC_SERVER | CLSCTX_LOCAL_SERVER, IID_IUnknown, reinterpret_cast<void**>(&pIWbemLocator)), QObject::tr("CoCreateInstance(WbemAdministrativeLocator) failed."));
        loop = true;
        while(loop) {
            if(pIWbemLocator != nullptr) {
                HRESULT res = pIWbemLocator->ConnectServer(strNamespace, nullptr, nullptr, nullptr, 0, nullptr, nullptr, &pWbemServices);
                if (res == S_OK) {
                    loop = false;
                } else {
                    delay(10);
                }
            } else {
                loop = false;
            }
        }

        CHECK_OK(pWbemServices->ExecQuery(strQL, strQueryDisks, WBEM_FLAG_RETURN_IMMEDIATELY, nullptr, &pEnumDisksObject), QObject::tr("Failed to query USB flash devices."));

        // Enumerate the received list of devices
        for (;;)
        {
            // Get the next available device or exit the loop
            ULONG uReturned;
            pEnumDisksObject->Next(WBEM_INFINITE, 1, &pDiskObject, &uReturned);
            if (uReturned == 0)
                break;

            VARIANT val;

            // Fetch the required properties and store them in the UsbDevice object
            deviceData = new UsbDevice;

            // User-friendly name of the device
            if (pDiskObject->Get(L"Model", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
            {
                if (val.vt == VT_BSTR)
                {
                    deviceData->m_VisibleName = QString::fromWCharArray(val.bstrVal);
                }
                VariantClear(&val);
            }

            // System name of the device
            if (pDiskObject->Get(L"DeviceID", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
            {
                if (val.vt == VT_BSTR)
                {
                    deviceData->m_PhysicalDevice = QString::fromWCharArray(val.bstrVal);
                }
                VariantClear(&val);
            }

            // Size of the devifce
            if (pDiskObject->Get(L"Size", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
            {
                if (val.vt == VT_BSTR)
                {
                    deviceData->m_Size = QString::fromWCharArray(val.bstrVal).toULongLong();
                }
                VariantClear(&val);
            }

            // Sector size of the devifce
            if (pDiskObject->Get(L"BytesPerSector", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
            {
                if (val.vt == VT_I4)
                {
                    deviceData->m_SectorSize = val.intVal;
                }
                VariantClear(&val);
            }

            // The device object is no longer needed, release it
            SAFE_RELEASE(pDiskObject);

            // Construct the request for listing the partitions on the current disk
            QString qstrQueryPartitions = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" + deviceData->m_PhysicalDevice + "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition";
            ALLOC_BSTR(strQueryPartitions, reinterpret_cast<const wchar_t*>(qstrQueryPartitions.utf16()));

            // Execute the query
            CHECK_OK(pWbemServices->ExecQuery(strQL, strQueryPartitions, WBEM_FLAG_RETURN_IMMEDIATELY, nullptr, &pEnumPartitionsObject), QObject::tr("Failed to query list of partitions."));

            // Enumerate the received list of partitions
            for (;;)
            {
                // Get the next available partition or exit the loop
                pEnumPartitionsObject->Next(WBEM_INFINITE, 1, &pPartitionObject, &uReturned);
                if (uReturned == 0)
                    break;

                // Fetch the DeviceID property and store it for using in the next request
                QString qstrQueryLetters = "";
                if (pPartitionObject->Get(L"DeviceID", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
                {
                    if (val.vt == VT_BSTR)
                    {
                        qstrQueryLetters = QString::fromWCharArray(val.bstrVal);
                    }
                    VariantClear(&val);
                }

                // The partition object is no longer needed, release it
                SAFE_RELEASE(pPartitionObject);

                // If DeviceID was fetched proceed to the logical disks
                if (qstrQueryLetters != "")
                {
                    // Construct the request for listing the logical disks related to the current partition
                    qstrQueryLetters = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" + qstrQueryLetters + "'} WHERE AssocClass = Win32_LogicalDiskToPartition";
                    ALLOC_BSTR(strQueryLetters, reinterpret_cast<const wchar_t*>(qstrQueryLetters.utf16()));

                    // Execute the query
                    CHECK_OK(pWbemServices->ExecQuery(strQL, strQueryLetters, WBEM_FLAG_RETURN_IMMEDIATELY, nullptr, &pEnumLettersObject), QObject::tr("Failed to query list of logical disks."));

                    // Enumerate the received list of logical disks
                    for (;;)
                    {
                        // Get the next available logical disk or exit the loop
                        pEnumLettersObject->Next(WBEM_INFINITE, 1, &pLetterObject, &uReturned);
                        if (uReturned == 0)
                            break;

                        // Fetch the disk letter and add it to the list of volumes in the UsbDevice object
                        if (pLetterObject->Get(L"Caption", 0, &val, 0, 0) == WBEM_S_NO_ERROR)
                        {
                            if (val.vt == VT_BSTR)
                            {
                                deviceData->m_Volumes << QString::fromWCharArray(val.bstrVal);
                            }
                            VariantClear(&val);
                        }

                        // The logical disk object is no longer needed, release it
                        SAFE_RELEASE(pLetterObject);
                    }

                    // Release the logical disks enumerator object and the corresponding query string
                    SAFE_RELEASE(pEnumLettersObject);
                    FREE_BSTR(strQueryLetters);
                }
            }

            // Release the partitions enumerator object and the corresponding query string
            SAFE_RELEASE(pEnumPartitionsObject);
            FREE_BSTR(strQueryPartitions);

            // The device information is now complete, append the entry
            l.append(*deviceData);
            // The object is now under the GUI control, nullify the pointer
            deviceData = nullptr;
        }
    }
    catch (QString errMessage)
    {
        // Something bad happened
        qDebug() << errMessage;
    }

    // The cleanup stage
    if (deviceData != nullptr)
        delete deviceData;

    SAFE_RELEASE(pLetterObject);
    SAFE_RELEASE(pPartitionObject);
    SAFE_RELEASE(pDiskObject);
    SAFE_RELEASE(pEnumDisksObject);
    SAFE_RELEASE(pEnumPartitionsObject);
    SAFE_RELEASE(pEnumLettersObject);
    SAFE_RELEASE(pWbemServices);
    SAFE_RELEASE(pIWbemLocator);

    FREE_BSTR(strNamespace);
    FREE_BSTR(strQL);
    FREE_BSTR(strQueryDisks);
    FREE_BSTR(strQueryPartitions);
    FREE_BSTR(strQueryLetters);
    return l;
}

bool ensureElevated()
{
    // In Windows the manifest already ensures elevated privileges
    return true;
}
