import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';

import {Extension, InjectionManager} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {UnlockDialog} from 'resource:///org/gnome/shell/ui/unlockDialog.js';

const MODIFIER_KEYS = new Set([
    Clutter.KEY_Shift_L,
    Clutter.KEY_Shift_R,
    Clutter.KEY_Shift_Lock,
    Clutter.KEY_Caps_Lock,
]);

function armBehindClock(dialog) {
    if (dialog._lsfpDestroyed || dialog._activePage !== dialog._clock)
        return;

    dialog._ensureAuthPrompt();

    const focus = global.stage.key_focus;
    if (focus === null || dialog._authPrompt?.contains(focus))
        dialog.grab_key_focus();
}

export default class LockscreenFingerprintExtension extends Extension {
    enable() {
        this._injections = new InjectionManager();

        this._injections.overrideMethod(UnlockDialog.prototype, 'open', orig => function (...args) {
            const ret = orig.apply(this, args);

            if (!this._lsfpSetup) {
                this._lsfpSetup = true;
                this.connect('destroy', () => {
                    this._lsfpDestroyed = true;
                });
                this._lsfpCapturedId = this.connect('captured-event', (_actor, event) => {
                    if (event.type() !== Clutter.EventType.KEY_PRESS ||
                        this._activePage !== this._clock ||
                        MODIFIER_KEYS.has(event.get_key_symbol()))
                        return Clutter.EVENT_PROPAGATE;

                    const focus = global.stage.key_focus;
                    if (this._authPrompt && focus && this._authPrompt.contains(focus))
                        this._showPrompt();

                    return Clutter.EVENT_PROPAGATE;
                });
            }

            armBehindClock(this);
            return ret;
        });

        this._injections.overrideMethod(UnlockDialog.prototype, '_maybeDestroyAuthPrompt', orig => function (...args) {
            orig.apply(this, args);
            if (this._lsfpRearmId)
                GLib.source_remove(this._lsfpRearmId);
            this._lsfpRearmId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
                this._lsfpRearmId = 0;
                armBehindClock(this);
                return GLib.SOURCE_REMOVE;
            });
        });

        const dialog = Main.screenShield?._dialog;
        if (dialog instanceof UnlockDialog)
            dialog.open();
    }

    disable() {
        this._injections.clear();
        this._injections = null;

        const dialog = Main.screenShield?._dialog;
        if (dialog?._lsfpRearmId) {
            GLib.source_remove(dialog._lsfpRearmId);
            dialog._lsfpRearmId = 0;
        }
        if (dialog?._lsfpCapturedId) {
            dialog.disconnect(dialog._lsfpCapturedId);
            dialog._lsfpCapturedId = 0;
            dialog._lsfpSetup = false;
        }
    }
}
