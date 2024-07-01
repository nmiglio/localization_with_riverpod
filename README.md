# test_gui

This is a proof of concept on how to use riverpod to achieve localization of the app.

The gui will react to a change of locale triggered via system settings and via the action button on the app bar.
The button will toggle through the supported languages (english and german).
The floating button will show a system dialog (date picker) to verify that also for this the proper locale is set (names/date format/text buttons).
