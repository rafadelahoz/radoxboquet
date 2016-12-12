package;

class RoomStorage
{
    var roomQueue : Array<String>;
    var roomData : Map<String, Array<PositionEntity>>;

    public function new()
    {
        roomQueue = [];
        roomData = new Map<String, Array<PositionEntity>>();
    }

    public function onEnter(to : String)
    {
        // For unpreviously tracked room
        if (roomQueue.indexOf(to) < 0)
        {
            // Put the new room at the head, remove the last room
            roomQueue.unshift(to);
            if (roomQueue.length > 3)
            {
                var lost : String = roomQueue.pop();
                roomData.remove(lost);
                trace("No longer tracking: " + lost);
            }
        }
        else
        {
            // Put the room at the head
            roomQueue.remove(to);
            roomQueue.unshift(to);

            trace("Returning to " + to);
        }

        var rostString : String = "ROST: [";
        for (room in roomQueue)
        {
            rostString += room + " ";
            if (roomData.exists(room))
                rostString += "(" + roomData.get(room).length + "), ";
        }

        rostString += "]";

        trace(rostString);
    }

    public function onLeave(from : String, fromData : Array<PositionEntity>)
    {
        // Store the former room data
        roomData.set(from, fromData);
    }

    function getData(room : String) : Array<PositionEntity>
    {
        if (roomData.exists(room))
            return roomData.get(room);
        else
            return [];
    }

    public function contains(room : String) : Bool
    {
        return roomQueue.indexOf(room) > -1;
    }

    public function storeEntities(world : World) : Array<PositionEntity>
    {
        var data : Array<PositionEntity> = [];

        // What to store??
        // Store enemies
        var stored : PositionEntity = null;
        var enemy : Enemy = null;
        for (entity in world.enemies)
        {
            enemy = cast(entity, Enemy);
            stored = new PositionEntity(enemy.x, enemy.y, PositionEntity.Enemy, EnemySpawner.getTypeName(enemy));
            data.push(stored);
        }

        return data;
    }

    public function spawnEntities(world : World)
    {
        var sceneName : String = world.sceneName;
        var storedData : Array<PositionEntity> = getData(sceneName);

        var spawned : Entity = null;
        for (entity in storedData)
        {
            spawned = null;
            switch (entity.type)
            {
                case PositionEntity.Enemy:
                    spawned = EnemySpawner.spawn(entity.x, entity.y, entity.name, world);
                default:
                    trace(entity + " would have been spawned");
            }

            if (spawned != null)
                world.addEntity(spawned);
        }
    }
}
