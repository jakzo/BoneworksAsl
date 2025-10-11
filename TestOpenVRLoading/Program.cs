// Simple console app to test BoneworksAslHelper.dll loading detection
// Usage: Place BoneworksAslHelper.dll and openvr_api.dll in the same directory as the
// executable

using System;
using System.IO;
using System.Reflection;
using System.Threading;

string exeDir = AppDomain.CurrentDomain.BaseDirectory;
string dllPath = Path.Combine(exeDir, "BoneworksAslHelper.dll");

Console.WriteLine("OpenVR Loading State Monitor");
Console.WriteLine("============================\n");

if (!File.Exists(dllPath))
{
    Console.WriteLine($"ERROR: BoneworksAslHelper.dll not found at: {dllPath}");
    Console.WriteLine("\nPlease ensure:");
    Console.WriteLine("1. BoneworksAslHelper.dll is in the same directory as this executable");
    Console.WriteLine("2. openvr_api.dll is also in the same directory");
    return;
}

Console.WriteLine($"Loading BoneworksAslHelper.dll from: {dllPath}");

try
{
    var assembly = Assembly.LoadFrom(dllPath);
    var type = assembly.GetType("BoneworksAslHelper");

    if (type == null)
    {
        Console.WriteLine("ERROR: Could not find BoneworksAslHelper type.");
        return;
    }

    var detector = Activator.CreateInstance(type);
    var initMethod = type.GetMethod("Initialize");
    var isLoadingMethod = type.GetMethod("IsLoading");
    var shutdownMethod = type.GetMethod("Shutdown");

    if (initMethod == null || isLoadingMethod == null || shutdownMethod == null)
    {
        Console.WriteLine("ERROR: Could not find required methods on BoneworksAslHelper.");
        return;
    }

    Console.WriteLine("Initializing OpenVR API...");
    initMethod.Invoke(detector, null);

    var dllPathProp = type.GetProperty("LoadedDllPath");
    string? loadedDllPath = dllPathProp?.GetValue(detector) as string;
    if (!string.IsNullOrEmpty(loadedDllPath))
    {
        Console.WriteLine($"✓ Loaded openvr_api.dll from: {loadedDllPath}");
    }
    Console.WriteLine("✓ OpenVR API initialized successfully!\n");
    Console.WriteLine("Monitoring loading state (press Ctrl+C to exit)...\n");

    bool shouldExit = false;
    Console.CancelKeyPress += (sender, e) =>
    {
        e.Cancel = true;
        shouldExit = true;
    };

    int counter = 0;
    bool lastState = false;

    while (!shouldExit)
    {
        bool isLoading = (bool)isLoadingMethod.Invoke(detector, null)!;

        // Print status with timestamp
        string timestamp = DateTime.Now.ToString("HH:mm:ss.fff");
        string status = isLoading ? "LOADING" : "NOT LOADING";
        string indicator = isLoading ? "🔴" : "🟢";

        Console.Write($"\r[{timestamp}] {indicator} Status: {status, -15} (checks: {++counter})");

        // Print a newline when state changes for easier reading
        if (isLoading != lastState)
        {
            Console.WriteLine($" <- STATE CHANGED!");
            lastState = isLoading;
        }

        Thread.Sleep(20);
    }

    Console.WriteLine("\n\nShutting down...");
    shutdownMethod.Invoke(detector, null);
    Console.WriteLine("✓ OpenVR API shutdown complete.");
}
catch (Exception ex)
{
    Console.WriteLine($"\nERROR: {ex.Message}");
    Console.WriteLine($"\nStack trace:\n{ex.StackTrace}");
}
