import "AsyncTask"
import "DynamicString"

class AsyncDownload : AsyncTask
{
   public DynamicString url {};
   public DynamicString save_path {};
   /* constructor */
   AsyncDownload()
   {
   }/* end AsyncDownload constructor */

   /* destructor */
   ~AsyncDownload()
   {
      delete url;
      delete save_path;
   }/* end AsyncDownload destructor */

   private bool execute()
   {
      bool opened = false;
      bool first = true;
      char relocation[4096];
      char *https_ptr = null;
      const unsigned int max_attempts = 5;
      unsigned int attempts = 0;
      HTTPFile network_file {};
      File remote_file {};

      if( !url || !url.array || !save_path || !save_path.array )
         return false;

      /* make sure we always get a terminated string */
      memset(relocation, '\0', 4096);
      /*FIXME: change from harded coded counted redirects and allow
       * to the task to follow the link */
      network_file.OpenURL(url.array, null, relocation);
      network_file.OpenURL(relocation, url.array, relocation);
      network_file.OpenURL(relocation, url.array, relocation);

      if(relocation[0] == '\0' )
         return false;

      //check https and change to http instead
      https_ptr = strstr(relocation, "https://");
      if(null != https_ptr) {
         https_ptr[0] = '\0';
         https_ptr[1] = 'h';
         https_ptr[2] = 't';
         https_ptr[3] = 't';
         https_ptr[4] = 'p';
	 https_ptr[5] = ':';
         https_ptr[6] = '/';
         https_ptr[7] = '/';
         remote_file = FileOpen(&https_ptr[1], read);
      }else {
         remote_file = FileOpen(relocation, read);
      }


      if(!remote_file)
         return false;

      remote_file.CopyTo(save_path.array);
      return true;

   }/* end execute func */

}/* end AsyncDownload class */
