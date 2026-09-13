/** @file
  Simple DXE driver demonstrating custom firmware code and
  ReadyToBoot event handling.
**/

#include <Uefi.h>

#include <Library/DebugLib.h>
#include <Library/UefiLib.h>

/**
  Handles the ReadyToBoot event.

  Writes a message to the active UEFI text console.

  @param[in] Event    ReadyToBoot event.
  @param[in] Context  Pointer to the EFI system table.
**/
STATIC
VOID
EFIAPI
HelloOnReadyToBoot (
  IN EFI_EVENT  Event,
  IN VOID       *Context
  );


/**
  Entry point for the HelloDxe driver.

  Registers the ReadyToBoot callback used to display a message after
  the platform console has been initialized.

  @param[in] ImageHandle  Handle of this driver image.
  @param[in] SystemTable  Pointer to the EFI system table.

  @retval EFI_SUCCESS  The ReadyToBoot callback was registered.
  @return               Error returned while creating the event.
**/
EFI_STATUS
EFIAPI
HelloDxeEntryPoint (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  EFI_STATUS  Status;
  EFI_EVENT   ReadyToBootEvent;

  DEBUG ((DEBUG_INFO, "HelloDxe: Entry point\n"));

  Status = EfiCreateEventReadyToBootEx (
             TPL_CALLBACK,
             HelloOnReadyToBoot,
             SystemTable,
             &ReadyToBootEvent
             );

  if (EFI_ERROR (Status)) {
    DEBUG ((
      DEBUG_ERROR,
      "HelloDxe: Failed to create ReadyToBoot event: %r\n",
      Status
      ));
    return Status;
  }

  DEBUG ((DEBUG_INFO, "HelloDxe: ReadyToBoot event registered\n"));

  return EFI_SUCCESS;
}


/**
  Handles the ReadyToBoot event.

  @param[in] Event    ReadyToBoot event.
  @param[in] Context  Pointer to the EFI system table.
**/
STATIC
VOID
EFIAPI
HelloOnReadyToBoot (
  IN EFI_EVENT  Event,
  IN VOID       *Context
  )
{
  EFI_SYSTEM_TABLE  *SystemTable;

  SystemTable = (EFI_SYSTEM_TABLE *)Context;

  DEBUG ((DEBUG_INFO, "HelloDxe: ReadyToBoot callback\n"));

  //
  // The console is expected to be initialized at ReadyToBoot, but
  // validate it before dereferencing the protocol interface.
  //
  if ((SystemTable == NULL) ||
      (SystemTable->ConOut == NULL) ||
      (SystemTable->ConOut->OutputString == NULL))
  {
    DEBUG ((
      DEBUG_WARN,
      "HelloDxe: ConOut is not available at ReadyToBoot\n"
      ));
    return;
  }

  SystemTable->ConOut->OutputString (
                         SystemTable->ConOut,
                         L"\r\nHello from MyUefiFw HelloDxe module!\r\n"
                         );

  DEBUG ((DEBUG_INFO, "HelloDxe: Message written to ConOut\n"));
}
