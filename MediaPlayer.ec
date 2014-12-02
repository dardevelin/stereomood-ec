import "ecere"
import "DynamicString"
#include <vlc/vlc.h>

class MediaPlayer
{
   private libvlc_instance_t *instance;
   private libvlc_media_player_t *media_player;
   private libvlc_media_t *media;
   private bool playing;

   MediaPlayer() {
      media_player = null;
      media = null;
      this.playing = false;
      instance = libvlc_new(0, null);
   }//end MediaPlayer constructor

   ~MediaPlayer() {
      libvlc_release(instance);
   }

   private property float track_progress {
      watchable
      get { return track_progress; }
      set { track_progress = value; }
   }//end track_progress property

   public property bool isReadyToRun {
      get { return null != media_player ? true : false; }
   }//end track_progress property

   public property bool isPlaying {
      get { return playing; }
   }//end isPlaying property

   public property uint progress {
      get {
         //0.0 to 1.0
         float p = 0.0;
         if( null == media_player )
            return 0;

         p = libvlc_media_player_get_position(media_player);
         return (uint)(p * 100);
      }
   }//end progress property

   public void play(const char* url) {
      if( null == url )
         return;

      if( null != media_player ) {
         libvlc_media_player_stop(media_player);
         libvlc_media_player_release(media_player);
         media_player = null;
      }

      media = libvlc_media_new_location(instance, url);
      media_player = libvlc_media_player_new_from_media(media);

      //no need to keep the media now
      libvlc_media_release(media);

      libvlc_media_player_play(media_player);
      this.playing = true;

   }//end Play func

   public void pause() {
      if( null == media_player )
         return;

      libvlc_media_player_pause(media_player);
      this.playing = false;
   }//end pause func

   public void resume() {
      if( null == media_player )
         return;

      libvlc_media_player_pause(media_player);
      this.playing = true;
   }//end resume func

   public void stop() {
      if ( null != media_player ) {
         libvlc_media_player_stop(media_player);
         libvlc_media_player_release(media_player);
         media_player = null;
         this.playing = false;
      }
   }

}//end MediaPlayer class