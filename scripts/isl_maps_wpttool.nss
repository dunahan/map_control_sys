#include "isl_maps_inc"

void main()
{
    object oArea = GetAreaFromLocation(GetItemActivatedTargetLocation());
    if (!GetLocalInt(oArea, "spawned"))
        SendMessageToPC(GetItemActivator(), "First activation prepares the spawns, second shows them.");

    CreateSpawnObjects(oArea);
}

