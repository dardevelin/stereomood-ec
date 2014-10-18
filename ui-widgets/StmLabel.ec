import "ecere"

enum e_status { error, inactive, fetching, ready };


class StmLabel : Label
{
   public void changeStatus(e_status code)
   {
      switch(code)
      {
         default:
         case e_status::inactive:
            this.caption = "status: Inactive";
            this.foreground = red;
            break;

         case e_status::error:
            this.caption = "status: Error";
            this.foreground = red;
            break;

         case e_status::fetching:
            this.caption = "status: Fetching";
            this.foreground = yellow;
            break;

         case e_status::ready:
            this.caption = "status: Ready";
            this.foreground = green;
            break;
      }/*end switch*/
   }/*end changeStatus */

}/* end StmLabel class */
