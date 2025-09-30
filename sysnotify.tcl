# This package implements optimal managment for system notifications,
# in order to avoid stacking of notification, when the notifications are sent faster than the limit imposed by the operating system.
# Created by Alexandru Dadalau (Meshparts GmbH)
# Free for any kind of use.

# Important. The system try icon must be initialized for this package to work:
# if {[tk systray exists]} {
#   tk systray destroy
# }
# tk systray create -image "some_image" -text "some text" -button3 "tk systray destroy"

# Test 1 (although 3 messages are initiated, only first and last are truely sent)
# ::sysnotify::Send "message 1"
# after 1000 ::sysnotify::Send "message 2"
# after 1000 ::sysnotify::Send "message 3"

package provide sysnotify 1.0

namespace eval ::sysnotify {
  ## Get most exact value of pi on this system.
  set pi [expr {acos(-1)}]
  # This is the delay that the operating system internally has for notification.
  # For Windows system, the delay was identified to be 7 seconds.
  variable sysnotify_delay 7
}

## This procedure aranges for the optimal delay between consecutive calls to the OS notification system.
  # Windows 11 automatically delays consecutive messages by 7 seconds, if the client sends messages quicker than that.
  # This procedures cancels a delayed, first message, if second message follows before the first message is sent.
  # This procedures computes the necessary delay based on the 7 seconds limit that the OS already has.
  # \param message string as required by the "tk sysnotify" (string should not be too long, which could lead to crash of the app)
  # \param title string as required by the "tk sysnotify" (e.g. Info or Warning)
proc ::sysnotify::Send {message {title Info}} {
  variable sysnotify_delay
  variable sysnotify_lasttime ;# This variable stores the clock time, at which the last system notificatio was sent.
  variable sysnotify_aftertoken ;# This variable stores the after token of last delayed system notification
  # If until now no system notification was sent
  if {![info exists sysnotify_lasttime]} {
    # Send notification without delay
    set delay 0
  # If at least one system notification was sent
  } else {
    # Calculate the time remaining, until this new notification can be sent without delay
    # This is the time passed since last notification was sent
    set dt [expr {[clock seconds]-$sysnotify_lasttime}]
    # If time passed is larger than the OS delay
    if {$dt>$sysnotify_delay} {
      # Send notification without delay
      set delay 0
    } else {
      # Delay notification by the seconds that remain until the OS delay is reached
      # This delay also makes possible that the next notification that might possibly come, can cancel this notification before it's actually sent.
      set delay [expr {$sysnotify_delay-$dt}]
    }
  }
  # If no delay is needed
  if {$delay==0} {
    # Send the notification immediately
    tk sysnotify $title $message
    # Remember the time at which this notification was sent
    ::sysnotify::SetTime
    # Delete the after token, if present
    unset -nocomplain sysnotify_aftertoken
  # If a delay is needed
  } else {
    # If the after toke is present
    if {[info exists sysnotify_aftertoken]} {
      # Cancel previous, still pending notification
      after cancel $sysnotify_aftertoken
    }
    # Send the new notification with the required delay
    # When the notification is sent, remember the time at which this notification was sent
    set sysnotify_aftertoken [after [expr {$dt*1000}] "tk sysnotify $title [list $message]; ::sysnotify::SetTime"]
  }
}
proc ::sysnotify::SetTime {} {
  variable sysnotify_lasttime [clock seconds]
}
