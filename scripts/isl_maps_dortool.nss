#include "isl_maps_inc"

void main()
{
    object oDoor = GetItemActivatedTarget();
    if (GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
    {
        SendMessageToPC(GetItemActivator(), "No door, won't work.");
        return;
    }

    else
        SetLocked(oDoor, FALSE);

    SendMessageToPC(GetItemActivator(), "Door unlocked.");
}

