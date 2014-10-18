import "ecere"

class PlaylistView : ListBox
{
   /* FIXME:[workaround] headers don't appear if hasHeader is set after fields
    * being added. Since we don't want to deal with setting up headers
    * everytime we bypass this problem by setting hasHeader in here
    * delay changes for when upstream fixes this issue */
   hasHeader = true;

   /* DataFields used to set and get data from view */
   DataField trackf { class(unsigned int), editable = false,
                        fixed = true, alignment = center , width = 35,
                        header = "track", userData = this, freeData = true };

   DataField titlef { class(String), editable = false, fixed = true,
                     alignment = left , width = 200, header = "title",
                     userData = "userdata", freeData = true };

   DataField locationf { class(String), editable = false, fixed = true,
                        alignment = left , width = 150, header = "location",
                        userData = "userdata", freeData = true };

   /* constructor */
   PlaylistView()
   {
      /* set out headers */
      this.AddField(this.trackf);
      this.AddField(this.titlef);
      this.AddField(this.locationf);

   }/*end PlaylistView constructor */

   /* destructor */
   ~PlaylistView()
   {
      delete this.trackf;
      delete this.titlef;
      delete this.locationf;
   }/*end PlaylistView destructor */

   public void addTrack(const unsigned int tracknum, const String title, const String location)
   {
      DataRow row = AddRow();
      row.SetData(this.trackf, tracknum);
      row.SetData(this.titlef, title);
      row.SetData(this.locationf, location);
      this.Update(null);
   }/* end addTrack pub::api*/

}/* end PlaylistView class */