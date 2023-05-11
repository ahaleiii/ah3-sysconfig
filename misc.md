# Miscellaneous Things

## Peripherals

### SIIG USB-C Dock

- <https://www.siig.com/usb-3-0-4k-dual-video-docking-station-usb-c.html>
- <https://support.displaylink.com/knowledgebase/articles/1886413>

To enable Night Light support on Windows, be sure to install the latest DisplayLink driver from the SIIG website.

Double check this registry value (may need to restart computer and/or unplug/plug the dock):

- `HKEY_LOCAL_MACHINE\SOFTWARE\DisplayLink\Core`. This section should exist after the driver is installed.
- Confirm that the `String value` of `EnableGammaRamp` exists and has a value of `true`.
