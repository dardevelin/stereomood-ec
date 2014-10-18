import "ecere"
import "PlaylistView"

class PlaylistTabView : Tab
{
   PlaylistView playlist;
   /*constructor */
   PlaylistTabView()
   {
      playlist = { parent = this, caption = "playlistView",
                   size = { this.tabControl.size.w,
                            this.tabControl.size.h - 60 },
                   position = { 0, 0 }, hasHeader = true };

   }/* end PlaylistTabView constructor */

   /* destructor */
   ~PlaylistTabView()
   {
      delete playlist;
   }/* end PlaylistTabView destructor */

}/* end PlaylistTabView class */

