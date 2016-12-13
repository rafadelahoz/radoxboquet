package;

class ActorSpawner
{
    public static function spawn(x : Float, y : Float, world : World, name : String, ?property : String = null, ?slide : Bool = false)
    {
        var entity : Entity = null;

        switch (name)
        {
            case Thesaurus.Corpse:
                entity = new CorpseActor(x, y, world, slide);
            case Thesaurus.Key:
                entity = new KeyActor(x, y, world, property);
            case Thesaurus.Hospital:
                entity = new Hospital(x, y, world, slide);
            default:
                entity = new ToolActor(x, y, world, name, property);
        }

        return entity;
    }
}
