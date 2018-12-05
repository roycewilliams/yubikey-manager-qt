import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {

    readonly property bool hasDevice: yubiKey.hasDevice
    property bool loadedReset
    onHasDeviceChanged: resetOnReInsert()

    function initiateReset() {
        confirmationPopup.show(
                    "Reset FIDO?",
                    "Are you sure you want to reset FIDO? This will delete all FIDO credentials, including FIDO U2F credentials.
This action cannot be undone!", function () {
    reInsertYubiKey.open()
})
    }

    function resetOnReInsert() {
        if (!hasDevice && reInsertYubiKey.visible) {
            loadedReset = true
        } else {
            if (loadedReset) {
                loadedReset = false
                touchYubiKey.open()
                yubiKey.fidoReset(function (resp) {
                    touchYubiKey.close()
                    if (resp.success) {
                        views.fido2()
                        snackbarSuccess.show(
                                    "FIDO applications have been reset")
                    } else {
                        if (resp.error_id === 'touch timeout') {
                            snackbarError.show(
                                        qsTr("A reset requires a touch on the YubiKey to be confirmed."))
                        } else if (resp.error_message) {
                            snackbarError.show(resp.error_message)
                        } else {
                            snackbarError.show(resp.error_id)
                        }
                    }
                })
            }
        }
    }

    CustomContentColumn {

        ViewHeader {
            breadcrumbs: [qsTr("FIDO2"), qsTr("Reset FIDO")]
        }

        Label {
            color: yubicoBlue
            text: qsTr("This action permanently deletes all FIDO credentials on the device (U2F & FIDO2), and removes the FIDO2 PIN")
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: constants.h3
        }

        ButtonsBar {
            finishCallback: initiateReset
            finishText: qsTr("Reset")
            finishTooltip: qsTr("Finish and perform the FIDO Reset")
        }
    }
}
