import "ecere"
import "StmLabel"
import "AsyncFetch"
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
         AsyncFetch asyncRequest { userData = this,
                                   success_cb = notifyOnTaskSuccess,
                                   failure_cb = notifyOnTaskFailure };

         /* lock the UI until we finished the task. see toggleInputState
          * comment to learn why */
         toggleInputState();
         /* set the mood for our task */
         asyncRequest.mood.concat(this.moodEntry.contents);
         asyncRequest.Create();
         /* let the user know our Task is executing */
         this.requestStatusLabel.changeStatus(fetching);

         /* make sure we don't have any UI glitch and update */
         Update(null);
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

   /* UI notification handlders. this functions control UI animations */
   /* when the user sets a mood a new task is initiated.
    * this newly created task calls-back either success or failure and
    * here we update the UI accordingly */

    bool notifyOnTaskSuccess(AsyncTask task)
    {
       /* AsyncFetch is really what we are dealing with */
       AsyncFetch fetch = (AsyncFetch)task;
       unsigned int num_tracks = 0;
       unsigned int iter = 0;

       if( !fetch || !fetch.playlist || !fetch.playlist.trackList
         || !fetch.playlist.trackList.count ) {
            return false;
       }

       num_tracks = fetch.playlist.trackList.count;

       for(iter = 0; iter < num_tracks; ++iter)
       {
         this.playlistView.addTrack(atoi(fetch.playlist.trackList[iter].trackNum),
                                    fetch.playlist.trackList[iter].title,
                                    fetch.playlist.trackList[iter].location);
       }/*end for loop */
       /*set the ui status label to ready*/
       this.requestStatusLabel.changeStatus(ready);
       /* unlock our input mechanisms */
       this.toggleInputState();
       return true;
    }/* end notifyOntaskSuccess func */

    bool notifyOnTaskFailure(AsyncTask task)
    {
       /* set the ui status label to error/fail */
       this.requestStatusLabel.changeStatus(error);
       /* unlock out input mechanisms */
       this.toggleInputState();
       return true;
    }/*end notifyOnTaskFailure func */

    /* since we are still not using tabbed view we lock the
     * input mechanisms in order to prevent a race condition
     * of multiple tasks trying to access the same playlistview.
     * this function helps us doing this without duplication */
   public void toggleInputState()
   {
      this.moodEntry.disabled = this.moodEntry.disabled ? false : true;
      this.fetchBtn.disabled = this.fetchBtn.disabled ? false : true;
   }/* end toggleInputState */

   bool OnCreate(void)
   {
      return true;
   }
}/* end StmWindow class */

StmWindow mainWindow {};
