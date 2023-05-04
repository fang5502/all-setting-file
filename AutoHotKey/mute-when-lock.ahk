; https://www.reddit.com/r/AutoHotkey/comments/y24fxe/mute_speakers_for_windows_lock_screen/

#SingleInstance, Force

SessionChange(true)
WM_WTSSESSION_CHANGE(wParam, lParam) {
    ; http://msdn.com/library/aa383828(vs.85,en-us)
    static WTS_SESSION_LOCK   := 0x7
    static WTS_SESSION_UNLOCK := 0x8

    static PrevMuteSetting

    ; mute on lockscreen
    if (wParam = WTS_SESSION_LOCK) {
        SoundGet, MuteSetting, , Mute
        PrevMuteSetting := MuteSetting

        if (MuteSetting = "Off")
            SoundSet, 1, , mute
    }

    ; unmute on log in
    if (wParam = WTS_SESSION_UNLOCK) {
        SoundGet, MuteSetting, , Mute

        if (MuteSetting = "On") && (PrevMuteSetting = "Off")
            SoundSet, 0, , mute
    }
}

/*
 notify = true 註冊指定的視窗以接收會話變更通知
 notify = false 取消註冊
*/
SessionChange(notify := true) {
    static WTS_CURRENT_SERVER      := 0
    static NOTIFY_FOR_ALL_SESSIONS := 1

    if (notify) {
        ; http://msdn.com/library/bb530723(vs.85,en-us)
        if !(DllCall("wtsapi32.dll\WTSRegisterSessionNotificationEx", "Ptr", WTS_CURRENT_SERVER, "Ptr", A_ScriptHwnd, "UInt", NOTIFY_FOR_ALL_SESSIONS))
            return false
        OnMessage(0x02B1, "WM_WTSSESSION_CHANGE")
    }
    else {
        ; http://msdn.com/library/bb530724(vs.85,en-us)
        OnMessage(0x02B1, "")
        if !(DllCall("wtsapi32.dll\WTSUnRegisterSessionNotificationEx", "Ptr", WTS_CURRENT_SERVER, "Ptr", A_ScriptHwnd))
            return false
    }
    return true
}
