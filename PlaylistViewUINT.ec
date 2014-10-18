import "ecere"

/* FIXME: [workaround] currently the toolkit does not allow to change
 * the color of a single row of a ListBox thus we do a little hack
 * on the representation of the ListBox first element though a custom
 * data type that defines a custom presentation/display mechanism
 * this way we can trick the UI to pain the entire row and thus get the
 * intended behavior. */

enum PlaylistViewUINTState { normal, fetching, ready, error };

class PlaylistViewUINT : struct
{
   public property unsigned int data
   {
      set { data = value; }
      get { return data; }
   }/* end property unsigned int data */

   unsigned int data;
   public PlaylistViewUINTState state;

   void OnDisplay(Surface surface, int x, int y, int width, void * fieldData, Alignment alignment, DataDisplayFlags displayFlags)
   {
      /* make it affect a ListBox entire row*/
      ListBox lb = fieldData;
      Box box = surface.box;

      switch(state)
      {
         case normal:
            break;

         case fetching:
            surface.background = yellow;
            break;

         case ready:
            surface.background = lightGreen;
            break;

         default:
         case error:
            surface.background = tomato;
            break;
      }/*end switch */

      surface.Clip({ 0, box.top, lb.clientSize.w, box.bottom});
      surface.textOpacity = false;
      surface.Clear(colorBuffer);   // This would clear the cell to the background color
      surface.Clip(box);
      data.OnDisplay(surface, x, y, width, fieldData, alignment, displayFlags);
   }/*end OnDisplay */

}/* end PlaylistViewUINT class */