# CHIP ESP32 OTA Requestor Example

A prototype application that demonstrates OTA Requestor capabilities.

Refer to
[setup ESP-IDF and CHIP Environment](#setup-esp-idf-and-chip-environment) and
[Build, Flash, Monitor, and Commissioning](#build-flash-monitor-and-commissioning)
guides to get started.

---

-   [Prerequisite](#prerequisite)
-   [Query for an OTA Image](#query-for-an-ota-image)
-   [ESP32 OTA Requestor with Linux OTA Provider](#esp32-ota-requestor-with-linux-ota-provider)
-   [Generate OTA image](#generate-ota-image)
-   Please refer
    [RPC console and Device Tracing](../../../docs/guides/esp32/rpc_console.md)
    for using RPC and device tracing

---

## Prerequisite

Before moving ahead, make sure you have
[OTA Provider](../../ota-provider-app/esp32) is commissioned and running.

### Query for an OTA Image

After commissioning is successful, announce OTA provider's presence using
chip-tool. On receiving this command OTA requestor will query for OTA image.

```
./out/debug/chip-tool otasoftwareupdaterequestor announce-ota-provider <PROVIDER NODE ID> 0 0 0 <REQUESTOR NODE ID> 0
```

Once the transfer is complete, OTA requestor sends ApplyUpdateRequest command to
OTA provider for applying the image. Device will restart on successful
application of OTA image.

### ESP32 OTA Requestor with Linux OTA Provider

-   Build the [Linux OTA Provider](../../ota-provider-app/linux)
-   Run the Linux OTA Provider with OTA image.

```
./out/debug/chip-ota-provider-app -f hello-world.bin
```

-   Provision the Linux OTA Provider using chip-tool

```
./out/debug/chip-tool pairing onnetwork 12345 20202021
```