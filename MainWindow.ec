import "ecere"
import "StmLabel"


class StmWindow : Window
{
   caption = "stereomood-ec";
   background = formColor;
   borderStyle = fixed;
   hasMinimize = true;
   hasClose = true;
   clientSize = { 616, 324 };
   anchor = { horz = -10, vert = -56 };


   /*UI head static 'input' mechanisms */

   EditBox moodEntry
   {
      this, caption = "moodEntry", size = { 382, 19 }, position = { 24, 24 }
   };/* end moodEntry instance */
   Button fetchBtn
   {
      this, caption = "Fetch", size = { 135, 21 }, position = { 464, 24 };
   };/* end fetchBtn instance */

   /*UI body - dynamic 'view' mechanism */
   //TODO: add tab control and playlist views inside tabs

   /*UI footer - static 'output' mechanism */
   StmLabel requestStatusLabel
   {
      this, caption = "status:", font = { "Tahoma", 8.25f, bold = true }, size = { 147, 13 }, position = { 24, 296 }
   };/* end StmLabel instance */
   Button downloadBtn
   {
      this, caption = "Download", size = { 151, 21 }, position = { 448, 288 }
   };/* end downloadBtn instance */

   bool OnCreate(void)
   {
      return true;
   }
}/* end StmWindow class */

StmWindow mainWindow {};
