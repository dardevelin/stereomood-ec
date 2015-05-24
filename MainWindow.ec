import "ecere"
import "StmLabel"
import "AsyncFetch"
import "AsyncDownload"
import "PlaylistTabView"
import "MediaPlayer"


class StmWindow : Window
{
   caption = "stereomood-ec";
   background = formColor;
   borderStyle = fixed;
   hasMinimize = true;
   hasClose = true;
   size = { 638, 350 };
   anchor = { horz = -2, vert = -15 };

   /*UI head static 'input' mechanisms */

   MediaPlayer player {};
   Timer trackUpdateTimer
   {
      userData = this, started = true, delay = 0.2;

      bool DelayExpired()
      {
         DataRow crow;
         this.trackProgressBar.progress = this.player.progress;

         //go to next track automatically
         if( (!this.player.isPaused && 99 == this.trackProgressBar.progress) ) {
            crow = this.playlistView.currentRow;
            if( crow.next ) {
               this.playlistView.SelectRow(crow.next);
               this.playlistView.OnLeftDoubleClick(0, 0, Modifiers {});
            }
         }

         this.volumeBar.progress = (this.player.volume/100);
         Update(null);
         return true;
      }
   };
   Button togglePlayPauseBtn
   {
      this, caption = $"▶", size = { 31, 21 }, position = { 456, 296 };

      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         if( this.player.isPlaying ) {
            this.player.pause();
            this.togglePlayPauseBtn.caption = "▶";
            return true;
         }

         if( this.player.isPaused ) {
            this.togglePlayPauseBtn.caption = "||";
            this.player.resume();
            return true;
         }

         if( null != this.playlistView.currentRow ) {
            DynamicString str_caption {};
            this.player.play(this.playlistView.currentRow.GetData(this.playlistView.locationf));
            str_caption.concatf("%s-%s",
               (char*)this.playlistView.currentRow.GetData(this.playlistView.titlef),
               (char*)(this.player.isPlaying ? "Playing" : "Failed"));

            this.playingStatus.caption = str_caption.array;

            if( this.player.isPlaying ) {
               this.togglePlayPauseBtn.caption = "||";
               return true;
            }
         }

         return false;
      }
   };

   void UpdateTogglePlayPauseBtnStatus() {
      this.togglePlayPauseBtn.caption = this.player.isPlaying ? "||" : "▶" ;
   }
   Button stopBtn
   {
      this, caption = $"■", size = { 31, 21 }, position = { 504, 296 };

      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         this.player.stop();
         this.UpdateTogglePlayPauseBtnStatus();
         return true;
      }
   };
   Button previousBtn
   {
      this, caption = $"⏮", size = { 31, 21 }, position = { 545, 296 };

      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         DataRow crow = this.playlistView.currentRow;

         if( crow && crow.previous ) {
            this.playlistView.SelectRow(crow.previous);
            this.playlistView.OnLeftDoubleClick(0, 0, Modifiers {});
         }

         return true;
      }
   };
   Button nextBtn
   {
      this, caption = $"⏭", size = { 31, 21 }, position = { 585, 296 };

      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         DataRow crow = this.playlistView.currentRow;

         if( crow && crow.next ) {
            this.playlistView.SelectRow(crow.next);
            this.playlistView.OnLeftDoubleClick(0, 0, Modifiers {});
         }
         return true;
      }
   };
   ProgressBar trackProgressBar
   {
      this, caption = $"trackProgressBar", size = { 244, 8 }, position = { 192, 296 }, range = 100;

      bool OnLeftButtonDown(int x, int y, Modifiers mods)
      {
         //find percentage
         //if the width is 100% and we have x, the percentage = x * 100/width
         //we cast everything to float for increased precision
         ((StmWindow)this.master).player.seek( ((float)((float)x)*((float)100)/((float)this.size.w)) );
         return true;
      }
   };
   ProgressBar volumeBar
   {
      this, caption = $"volumeBar", size = { 244, 8 }, position = { 192, 312 }, range = 100;

      bool OnLeftButtonDown(int x, int y, Modifiers mods)
      {
         ((StmWindow)this.master).player.set_volume( ((float)((float)x)*((float)100)/((float)this.size.w)) );
         return true;
      }
   };
   EditBox moodEntry
   {
      this, caption = "moodEntry", size = { 382, 19 }, position = { 24, 24 };

      bool OnKeyDown(Key key, unichar ch)
      {
         if( enter == key ) {
            ((StmWindow)this.master).fetchBtn.NotifyClicked(this.master,((StmWindow)this.master).fetchBtn, 0, 0, Modifiers {});
         }

         return EditBox::OnKeyDown(key, ch);
      }
   };/* end moodEntry instance */
   Button fetchBtn
   {
      this, caption = "Fetch", size = { 151, 21 }, position = { 464, 24 };

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
      this, caption = "playlistView", size = { 588, 198 }, position = { 24, 64 }, hasHeader = true, true;

      bool OnLeftDoubleClick(int x, int y, Modifiers mods)
      {
         DynamicString str_caption {};
         ((StmWindow)this.master).player.play(((StmWindow)this.master).playlistView.currentRow.GetData(((StmWindow)this.master).playlistView.locationf));
         ((StmWindow)this.master).UpdateTogglePlayPauseBtnStatus();

         str_caption.concatf("%s-%s",
            (char*)((StmWindow)this.master).playlistView.currentRow.GetData( ((StmWindow)this.master).playlistView.titlef ),
            (char*)(((StmWindow)this.master).player.isPlaying ? "Playing" : "Failed"));

         ((StmWindow)this.master).playingStatus.caption = str_caption.array;

         return PlaylistView::OnLeftDoubleClick(x, y, mods);
      }
   };/* end PlaylistView instance */

   /*UI footer - static 'output' mechanism */
   StmLabel requestStatusLabel
   {
      this, caption = "status:", font = { "Tahoma", 8.25f, bold = true }, size = { 147, 13 }, position = { 24, 296 }
   };
   Label playingStatus
   {
      this, caption = "", font = { "Tahoma", 8.25f, bold = true }, size = { 234, 13 }, position = { 192, 272 }
   };/* end StmLabel instance */
   Button downloadBtn
   {
      this, caption = "Download", size = { 167, 21 }, position = { 448, 264 };

      bool NotifyClicked(Button button, int x, int y, Modifiers mods)
      {
         FileDialog saveDialog { type = save };
         DialogResult dialog_res;
         OldList list {};
         char *link = null;

         //get the selected list
         this.playlistView.GetMultiSelection(list);

         if( 0 == list.count )
            return false;

         if( 1 == list.count ) {
            link = this.playlistView.currentRow.GetData(this.playlistView.locationf);
            saveDialog.filePath = link;
         }

         /* get appropriate default path for each OS */
         #if defined(_WIN32) || defined(WIN32) || defined(WIN64) || defined(_WIN64) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__BORLANDC__)
            saveDialog.currentDirectory = getenv("Desktop");
         #else
            saveDialog.currentDirectory = getenv("HOME");
         #endif

         dialog_res = saveDialog.Modal();

         if( dialog_res == yes || dialog_res == ok ) {

            while( list.count ) {

               AsyncDownload asyncDownload {
                  userData = ((DataRow)((OldLink)list.first).data).GetData(this.playlistView.trackf),
                  success_cb = notifyOnDownloadSuccess,
                  failure_cb = notifyOnDownloadFailure };

               asyncDownload.url.concat( link ? link : ((DataRow)((OldLink)list.first).data).GetData(this.playlistView.locationf));

               asyncDownload.save_path.concatf("%s/%d_%s.mp3",saveDialog.currentDirectory,
                  (int)((DataRow)(((OldLink)list.first).data)).GetData(this.playlistView.trackf),
                  (char*)((DataRow)(((OldLink)list.first).data)).GetData(this.playlistView.titlef));

               asyncDownload.Create();

               list.Delete(list.first);
            }//end while list.count
            return true;
         }
         /* we failed to select a path don't proceed */
         return false;
      }/*end NotifyClicked downloadBtn*/
   };/* end downloadBtn instance */

   /* UI notification handlders. this functions control UI animations */
   /* when the user sets a mood a new task is initiated.
    * this newly created task calls-back either success or failure and
    * here we update the UI accordingly */

    /* AsyncFetch succcess */

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

    /* AsyncFetch failure */

   bool notifyOnTaskFailure(AsyncTask task)
   {
       /* set the ui status label to error/fail */
       this.requestStatusLabel.changeStatus(error);
       /* unlock out input mechanisms */
       this.toggleInputState();
       return true;
   }/*end notifyOnTaskFailure func */

    /* AsyncDownload succcess */

   bool notifyOnDownloadSuccess(AsyncTask task)
   {
       AsyncDownload handle = (AsyncDownload)task;

       ((PlaylistViewUINT)handle.userData).state = ready;
       this.Update(null);
       return true;
   }/*end notifyOnDownloadSuccess func */

    /* AsyncDownload failure */

   bool notifyOnDownloadFailure(AsyncTask task)
   {
       AsyncDownload handle = (AsyncDownload)task;

      ((PlaylistViewUINT)handle.userData).state = error;
      this.Update(null);
      return true;
   }/*end notifyOnDownloadFailure func */

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

StmWindow mainWindow { };
