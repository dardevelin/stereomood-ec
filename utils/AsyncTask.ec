import "ecere"

class AsyncTask : Thread
{
   public void *userData;

   virtual bool any_object::success_cb(AsyncTask task);
   virtual bool any_object::failure_cb(AsyncTask task);
   virtual bool execute();

   bool exit_status;

   private void exec(void)
   {
      /* create the actual thread */
      if(!created)
         Create();
      else{
         exit_status = execute();
      }
   }

   unsigned int Main()
   {
      exit_status = true;
      /*  create the thread and yield, second run execute */
      exec();
      Sleep(0);
      ((GuiApplication)__thisModule.application).Lock();

      if( exit_status )
         success_cb(userData, this);
      else
         failure_cb(userData, this);

      ((GuiApplication)__thisModule.application).Unlock();
      return 0;
   }
}/* end AsyncTask class */
