import "ecere"
import "StmLabel"
import "PlaylistTabView"


class StmWindow : Window
{
   caption = "stereomood-ec";
   background = formColor;
   borderStyle = fixed;
   hasMinimize = true;
   hasClose = true;
   clientSize = { 616, 324 };
   anchor = { horz = -10, vert = -56 }

   /*UI head static 'input' mechanisms */

   EditBox moodEntry
   {
      this, caption = "moodEntry", size = { 382, 19 }, position = { 24, 24 }
   };/* end moodEntry instance */

   Button fetchBtn
   {
      this, caption = "Fetch", size = { 135, 21 }, position = { 464, 24 };
      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         /*FIXME: tabControl usage is currently suspended, thus
          * this does not apply for now. *//*
         PlaylistTabView tab;
         tab = { parent = tabControl, text = this.moodEntry.contents };
         tab.Create();
         tab.SelectTab();
         tab.tabControl.Update(null);
         */
         return true;
      }/* end NotifyClicked downloadBtn */

   };/* end fetchBtn instance */

   /*UI body - dynamic 'view' mechanism */

   /* FIXME: tabControl and tabs don't fill the intended purpose of
    * the visual style wanted for the application, therefor its use is
    * deferred for now. until either a new tabControl is created or a
    * path of achieving the intended behavior is found *//*
   TabControl tabControl
   {
      parent = this, anchor = { left = 0, top = 60, right = 0, bottom = 60 };
   };/* end tabControl instance */
   /* using PlaylistView directly */
   PlaylistView playlistView
   {
      this, caption = "playlistView", size = { 572, 198 },
      position = { 24, 64 }, hasHeader = true;
   };/* end PlaylistView instance */

   /*UI footer - static 'output' mechanism */
   StmLabel requestStatusLabel
   {
      this, caption = "status:", font = { "Tahoma", 8.25f, bold = true },
      size = { 147, 13 }, position = { 24, 296 };
   };/* end StmLabel instance */

   Button downloadBtn
   {
      this, caption = "Download", size = { 151, 21 }, position = { 448, 288 };
   };/* end downloadBtn instance */

   bool OnCreate(void)
   {
      return true;
   }
}/* end StmWindow class */

StmWindow mainWindow {};
