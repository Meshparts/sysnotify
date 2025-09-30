This package implements optimal managment for system notifications,
in order to avoid stacking of notification, when the notifications are sent faster than the limit imposed by the operating system.
Created by Alexandru Dadalau (Meshparts GmbH)
Free for any kind of use.

# Important. The system try icon must be initialized for this package to work:
if {[tk systray exists]} {
  tk systray destroy
}
tk systray create -image "some_image" -text "some text" -button3 "tk systray destroy"

# Test 1 (although 3 messages are initiated, only first and last are truely sent)
::sysnotify::Send "message 1"
after 1000 ::sysnotify::Send "message 2"
after 1000 ::sysnotify::Send "message 3"
