#include "isl_maps_inc"

void main()
{
    object oArea = GetAreaFromLocation(GetItemActivatedTargetLocation());
    if (!GetLocalInt(oArea, "spawned"))
        SendMessageToPC(GetItemActivator(), "First activation prepares the placeables, second shows them.");

    CreateUseablePlaceables(oArea);
}

