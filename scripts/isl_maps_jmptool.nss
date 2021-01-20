#include "isl_maps_inc"

void main()
{
    if (GetIsPC(GetItemActivatedTarget()))
        DoJumpToTarget(GetItemActivator(), GetStartingLocation());
    else
        DoJumpToTarget(GetItemActivator(), GetItemActivatedTargetLocation());
}

