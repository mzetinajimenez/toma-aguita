# Widget Setup Instructions

Good news! You've already created the Widget Extension target. Now we just need to clean up the auto-generated files and configure the widget properly.

## ✅ What You've Already Done

- Created the `TomaAguitaWidgetExtension` target
- The widget extension is building successfully
- The widget is embedded in the main app

## 📝 What You Need to Do Manually in Xcode

### Step 1: Remove Auto-Generated Widget Files

Xcode created some template files we don't need. Let's remove them:

1. Open `toma-aguita.xcodeproj` in Xcode
2. In the Project Navigator (left sidebar), expand the `TomaAguitaWidget` folder
3. **Delete these files** (select each file, right-click, choose "Delete" → "Move to Trash"):
   - `TomaAguitaWidgetLiveActivity.swift`
   - `TomaAguitaWidgetControl.swift`
   - `AppIntent.swift`

   ⚠️ **Keep** `Info.plist` - don't delete this file!

### Step 2: Verify New Widget Files Are in Target

The correct widget files have been created. Verify they're included in the target:

1. In Project Navigator, select `TomaAguitaWidget/TomaAguitaWidget.swift`
2. In the **File Inspector** (right sidebar), under **Target Membership**, verify:
   - ✅ `TomaAguitaWidgetExtension` is **checked**
3. Repeat for `TomaAguitaWidget/TomaAguitaWidgetBundle.swift`
   - ✅ `TomaAguitaWidgetExtension` is **checked**

### Step 3: Share Model Files with Widget Target

The widget needs access to your data models:

1. In Project Navigator, navigate to `toma-aguita/Models/WaterIntakeRecord.swift`
2. Select the file
3. In the **File Inspector** (right sidebar), under **Target Membership**, check **both**:
   - ✅ `toma-aguita`
   - ✅ `TomaAguitaWidgetExtension`

**Optional:** You can also add `WaterIntakeManager.swift` to both targets if you want (not strictly necessary for the current widget implementation, but good for future features).

### Step 4: Build and Test

1. Select the **toma-aguita** scheme (not the widget scheme)
2. Choose your target device or simulator
3. Click **Run** (⌘R)
4. The app should build successfully!

If you get build errors:
- Make sure you deleted the old files in Step 1
- Clean Build Folder (⌘⇧K) and rebuild
- Verify the target memberships in Steps 2 and 3

## 🎯 Adding the Widget to Your Lock Screen

Once the app builds successfully:

### On a Real Device:

1. **Lock your iPhone**
2. **Long press on the lock screen** to enter editing mode
3. Tap **Customize**
4. Tap the area **below the time** (where widgets go)
5. Tap the **+ Add Widget** button
6. Search for "Toma Aguita" or scroll to find it
7. Select the **circular widget** (it should be the only one)
8. Tap outside the widget area to position it
9. Tap **Done**

### On a Simulator:

Lock screen widgets can be tricky to test on simulators. For the best experience:
- Test the main app functionality in the simulator
- Test the lock screen widget on a real device

## 🧪 Testing the Widget

1. **Open the app** and add some water (try tapping +1 or +2)
2. **Lock your device** and check the widget
3. The widget shows your current progress (e.g., "3 of 8")
4. The circular ring should fill based on your progress
5. Add more water in the app, the widget updates within an hour (or immediately if you remove/re-add it)

## 🐛 Troubleshooting

### Widget not showing in gallery
- Verify TomaAguitaWidget.swift and TomaAguitaWidgetBundle.swift are in the TomaAguitaWidgetExtension target
- Clean and rebuild the project
- Restart the simulator/device

### Widget shows "0 of 8" even though you logged water
- Verify WaterIntakeRecord.swift is shared with TomaAguitaWidgetExtension target (Step 3)
- Try removing and re-adding the widget to force a refresh
- Check the Xcode console for any error messages from the widget

### Build errors about missing types
- Make sure you deleted all three auto-generated files (LiveActivity, Control, AppIntent)
- Verify the Model files are shared with the widget target
- Clean build folder (⌘⇧K) and try again

### "Type 'TomaAguitaWidget' is ambiguous"
- This means both the old and new widget files exist
- Make sure you deleted the old files (Step 1)
- Clean build folder

## ✨ You're Done!

Once the app builds and the widget appears on your lock screen, you're all set! The widget will:
- Show your current water intake
- Display a circular progress ring
- Update automatically every hour
- Auto-reset at midnight along with the app

Enjoy staying hydrated! 💧

## 📚 Additional Notes

**Widget Update Frequency:**
- Widgets update automatically every hour
- For immediate updates, remove and re-add the widget
- iOS may limit widget updates if battery is low

**Data Sharing:**
- The app and widget share the same SwiftData container
- No App Groups configuration needed for basic functionality
- Data persists across app launches and reboots
