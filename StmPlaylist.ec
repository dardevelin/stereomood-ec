import "ecere"

/* json object representation in order to simplify decoding
 * and encoding.
 * NOTE: we always get an StmPlaylist even when just adding new
 * new tracks to the same original request. */

class StmTrack
{
   public:
      String location;
      String title;
      String creator;
      String image;
      String trackNum;
      String identifier;
      String code;
      String owner;
}/* end StmTrack class */

class StmPlaylist
{
   public:
      String title;
      String creator;
      String tracksTotal;
      Array<StmTrack> trackList {};
}/* end StmPlaylist class */