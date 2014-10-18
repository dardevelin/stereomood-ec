import "ecere"

enum StmLabelState { error, inactive, fetching, ready };


class StmLabel : Label
{
   public void changeStatus(StmLabelState code)
   {
      switch(code)
      {
         default:
         case StmLabelState::inactive:
            this.caption = "status: Inactive";
            this.foreground = red;
            break;

         case StmLabelState::error:
            this.caption = "status: Error";
            this.foreground = red;
            break;

         case StmLabelState::fetching:
            this.caption = "status: Fetching";
            this.foreground = yellow;
            break;

         case StmLabelState::ready:
            this.caption = "status: Ready";
            this.foreground = green;
            break;
      }/*end switch*/
   }/*end changeStatus */

}/* end StmLabel class */
