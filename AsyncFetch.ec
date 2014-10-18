import "ecere"
import "AsyncTask"
import "StmPlaylist"
import "DynamicString"

class AsyncFetch : AsyncTask
{
   public DynamicString mood {};

   private StmPlaylist playlist;
   private DynamicString url {};
   private unsigned int url_page;

   /* constructor */
   AsyncFetch()
   {
   }/* end AsyncFetch constructor */

   /* destructor */
   ~AsyncFetch()
   {
      if(null != this.playlist) {
         delete this.playlist;
      }

      delete mood;
      delete url;
   }/* end AsyncFetch destructor */

   /* our actual task */
   private bool execute()
   {
      StmPlaylist playlistHandle;
      const unsigned int max_attempts = 5;
      unsigned int ntracks = 0;
      unsigned int totalTracks = 0;
      unsigned int attempts = 0;

      //always start with page 1
      this.url_page = 1;
      if( !this.build_url() )
         return false;

      this.playlist = this.get_playlist(this.url);

      /*since some moods don't have any tracks,
       *we check for 0 == trackList.count to able to fail gracefully */
      if( !this.playlist || 0 == this.playlist.trackList.count )
         return false;

      //how many tracks do we currently have
      ntracks = this.playlist.trackList.count;
      //how many do we want
      totalTracks = atoi( this.playlist.tracksTotal );

      while( totalTracks > ntracks )
      {
         ++this.url_page;
         if( !this.build_url() )
            return false;

         playlistHandle = this.get_playlist(this.url);

         if( !playlistHandle ) {
            if( max_attempts > ++attempts ) {
                  printf("\nerror: trying[%d]\n", attempts);
                  --this.url_page; //try same page
                  continue;
            }
         }

         if( !this.merge_playlists(this.playlist, playlistHandle) ) {
            printf("\nerror: failed to merge lists");
            return false;
         }

         //make sure each url has the same ammout of chances
         attempts = 0;
         //add the newly obtained tracks
         ntracks += playlistHandle.trackList.count;
         //dont leak, delete the allocated handle as the tracks were passed
         delete playlistHandle;

      }/*end while */

      return true;
   }/* end execute func */

   /* helper functions for the task */
   private bool build_url()
   {
      char *p = null;
      char *epos = null;
      if( this.mood && this.mood.count <= 0 )
         return false;

      //skip whitespace
      p = mood.array;
      while( isspace(*p) )
         ++p;

      if( !p || *p == '\0' || isspace(*p) || strlen(p) <= 0 )
         return false;

      //find where trailing whitespace starts
      epos = strchr(p, '\0');
      while( null != epos-- && epos != p && isspace(*epos) )
         ;

      this.url.RemoveAll();
      this.url.concatf(
         "http://www.stereomood.com/mood/%.*s/playlist.json?save&index=%d",
          epos-p+1, p, url_page);
      //debug msg
      //printf("\nbuilt url: %s | returning true ", url.array);

      return true;
   }/* end build_url helper func */

   private StmPlaylist get_playlist(DynamicString url)
   {
      bool error = false;
      StmPlaylist playlist;

      JSONParser j_parser {};
      JSONResult j_result;

      if( !url ) {
         printf("\nerror: no url");
         return null;
      }

      playlist = {};

      j_parser.f = FileOpen(url.array, read);

      //see if we were able to open the url
      if( j_parser.f )
         j_result = j_parser.GetObject( class(StmPlaylist), &playlist);

      //handle errors:
      switch(j_result)
      {
         case noItem:
            printf("\nerror: j_result, noItem\n");
            error = true;
            break;
         case syntaxError:
            printf("\nerror: j_result, syntaxError\n");
            error = true;
            break;
         case typeMismatch:
            printf("\nerror: j_result, typeMismatch\n");
            error = true;
            break;
         case success:
            printf("\nsuccess: j_result\n");
            break;
         default:
            printf("\nerror: j_result, no data, probably parser problem\n");
            error = true;
            break;
      }/*end switch */

      if( error ) {
         delete playlist;
         return null;
      }

      return playlist;
   }/* end getPlaylist helper func */

   private bool merge_playlists(StmPlaylist to, StmPlaylist from)
   {

      unsigned int iter = 0;
      unsigned int total;

      if( !to || !from )
         return false;

      total = from.trackList.count;

      while( ++iter != total )
      {
         to.trackList.Add( from.trackList[iter] );
          //leave this in here, debugging utility
         /*
         printf("\niplayAdd|[num]:%s|[title]:%s|[location]:%s)",
            from.trackList[iter].trackNum,
            from.trackList[iter].title,
            from.trackList[iter].location);
         */
      }

      return true;
   }/*end merge_playlists */

}/* end AsyncFetch class */