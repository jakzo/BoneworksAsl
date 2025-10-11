using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

public class BoneworksAslHelper
{
    // Found by counting IVRCompositor methods in openvr.h
    const int VTableIndex_IsCurrentSceneFocusAppLoading = 47;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr LoadLibrary(string lpFileName);

    [DllImport("openvr_api", CallingConvention = CallingConvention.Cdecl)]
    private static extern uint VR_InitInternal(
        ref EVRInitError peError,
        EVRApplicationType eApplicationType
    );

    [DllImport("openvr_api", CallingConvention = CallingConvention.Cdecl)]
    private static extern void VR_ShutdownInternal();

    [DllImport("openvr_api", CallingConvention = CallingConvention.Cdecl)]
    private static extern IntPtr VR_GetGenericInterface(
        [MarshalAs(UnmanagedType.LPStr)] string pchInterfaceVersion,
        ref EVRInitError peError
    );

    private enum EVRApplicationType
    {
        VRApplication_Other = 0,
        VRApplication_Scene = 1,
        VRApplication_Overlay = 2,
        VRApplication_Background = 3,
        VRApplication_Utility = 4,
    }

    private enum EVRInitError
    {
        None = 0,
    }

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    private delegate bool IsCurrentSceneFocusAppLoadingDelegate(IntPtr thisPtr);

    private IntPtr openvrDllHandle = IntPtr.Zero;
    private IntPtr compositorPtr = IntPtr.Zero;
    private IsCurrentSceneFocusAppLoadingDelegate? isLoadingFunc = null;
    private bool initialized = false;

    private static string FindBoneworksDirectory()
    {
        var proc =
            Process
                .GetProcesses()
                .FirstOrDefault(p =>
                    p.ProcessName.Equals("BONEWORKS", StringComparison.OrdinalIgnoreCase)
                ) ?? throw new Exception("BONEWORKS process not found");
        if (proc.MainModule == null)
            throw new Exception("BONEWORKS main module is null");
        return Path.GetDirectoryName(proc.MainModule.FileName)
            ?? throw new Exception("Could not determine BONEWORKS directory");
    }

    private void LoadOpenVRDll()
    {
        if (openvrDllHandle != IntPtr.Zero)
            return;
        openvrDllHandle = LoadLibrary(
            Path.Combine(FindBoneworksDirectory(), "BONEWORKS_Data", "Plugins", "openvr_api.dll")
        );
        if (openvrDllHandle == IntPtr.Zero)
            throw new Exception("Failed to load openvr_api.dll");
    }

    public void Initialize()
    {
        if (initialized)
            return;

        LoadOpenVRDll();

        var error = EVRInitError.None;
        VR_InitInternal(ref error, EVRApplicationType.VRApplication_Background);
        if (error != EVRInitError.None)
            throw new Exception($"VR_InitInternal failed: {(int)error} ({error})");

        try
        {
            compositorPtr = VR_GetGenericInterface("IVRCompositor_029", ref error);
            if (error != EVRInitError.None || compositorPtr == IntPtr.Zero)
                throw new Exception($"VR_GetGenericInterface failed: {error}");

            IntPtr vtablePtr = Marshal.ReadIntPtr(compositorPtr);
            IntPtr funcPtr = Marshal.ReadIntPtr(
                vtablePtr,
                VTableIndex_IsCurrentSceneFocusAppLoading * IntPtr.Size
            );
            if (funcPtr == IntPtr.Zero)
                throw new Exception("Function pointer is null");

            isLoadingFunc =
                Marshal.GetDelegateForFunctionPointer<IsCurrentSceneFocusAppLoadingDelegate>(
                    funcPtr
                );
            initialized = true;
        }
        catch
        {
            VR_ShutdownInternal();
            throw;
        }
    }

    public bool IsLoading()
    {
        if (!initialized || isLoadingFunc == null || compositorPtr == IntPtr.Zero)
            return false;
        return isLoadingFunc(compositorPtr);
    }

    public void Shutdown()
    {
        if (!initialized)
            return;
        try
        {
            VR_ShutdownInternal();
        }
        catch { }
        initialized = false;
        compositorPtr = IntPtr.Zero;
        isLoadingFunc = null;
    }
}
