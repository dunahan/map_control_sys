#include "x0_i0_stringlib"

const string ISL_MAPS_RESREF_PORTPLC = "portals";
const string ISL_MAPS_RESREF_JMPTOOL = "isl_maps_jmptool";
const string ISL_MAPS_RESREF_WPTTOOL = "isl_maps_wpttool";
const string ISL_MAPS_RESREF_PLCTOOL = "isl_maps_plctool";
const string ISL_MAPS_RESREF_DORTOOL = "isl_maps_dortool";
const float  ISL_MAPS_CONFLOAT_DELAY = 1.0;
const float  ISL_MAPS_SPACER_PORTPLC = 1.5;
const int dbg = 1;

void d(string s)
{
    if (dbg == 1)   SendMessageToPC(GetFirstPC(), s);
}

string l(location loc)
{
    vector v = GetPositionFromLocation(loc);
    float f = GetFacingFromLocation(loc);

    return GetTag(GetAreaFromLocation(loc))+";"+FloatToString(v.x,3,1)+";"+
                                            ";"+FloatToString(v.y,3,1)+";"+
                                            ";"+FloatToString(v.z,3,1)+";"+
                                            FloatToString(f,3,1);
}

object GetAreaByResRef(string sResRef)
{
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (GetResRef(oArea) == sResRef)
            return oArea;

        oArea = GetNextArea();
    }

    return OBJECT_INVALID;
}

object GetTransitionTargetInArea(object oArea)
{
    object oTarget = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTarget))
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE && GetResRef(oTarget) == ISL_MAPS_RESREF_PORTPLC)
            return oTarget;

        oTarget = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

location GetValidLocationInArea(object oArea)
{
    location lTarget = Location(oArea, Vector(1.0, 1.0, 0.0), 0.0);
    object oChicken = CreateObject(OBJECT_TYPE_CREATURE, "nw_chicken", lTarget);
    location locChicken = GetLocation(oChicken);
    DestroyObject(oChicken, ISL_MAPS_CONFLOAT_DELAY);

    return locChicken;
}

void StoreWaypoints(object oArea)
{
    int i, c = GetLocalInt(oArea, "w_spawned"); object oWaypoint, oFlag;
    if (c<=0)                         return;                                   // do only if there are waypoints saved!
    if (GetLocalInt(oArea, "w_done")) return;                                   // do only once!

    for (i = 1 ; i <= c; i++)
    {
        oWaypoint = GetLocalObject(oArea, "w_"+IntToString(i));
        oFlag = CreateObject(OBJECT_TYPE_PLACEABLE, "spawnflag", GetLocation(oWaypoint));

        if (GetLocalString(oWaypoint, "NESS_TAG") == "")
            SetName(oFlag, GetTag(oWaypoint)+" / "+GetName(oWaypoint));
        else
            SetName(oFlag, GetLocalString(oWaypoint, "NESS")+" / "+GetLocalString(oWaypoint, "NESS_TAG"));
    }

    SetLocalInt(oArea, "w_done", 1);
}

void CreateSpawnObjects(object oArea)
{
    if (GetLocalInt(oArea, "w_spawned"))
    {
        StoreWaypoints(oArea);
        return;
    }

    object oWaypoint = GetFirstObjectInArea(oArea);  int i;
    while (GetIsObjectValid(oWaypoint))
    {
        if (GetObjectType(oWaypoint) == OBJECT_TYPE_WAYPOINT)
        {
            i++;
            SetLocalObject(oArea, "w_"+IntToString(i), oWaypoint);              d(IntToString(i)+") "+GetName(oWaypoint));
        }

        oWaypoint = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, "w_spawned", i);
}

void StorePlaceables(object oArea)
{
    int i, c = GetLocalInt(oArea, "p_spawned"); object oWaypoint, oFlag;
    if (c<=0)                         return;                                   // do only if there are waypoints saved!
    if (GetLocalInt(oArea, "p_done")) return;                                   // do only once!

    for (i = 1 ; i <= c; i++)
    {
        oWaypoint = GetLocalObject(oArea, "p_"+IntToString(i));
        oFlag = CreateObject(OBJECT_TYPE_PLACEABLE, "x3_plc_slightb", GetLocation(oWaypoint));
    }

    SetLocalInt(oArea, "p_done", 1);
}

void CreateUseablePlaceables(object oArea)
{
    if (GetLocalInt(oArea, "p_spawned"))
    {
        StorePlaceables(oArea);
        return;
    }

    object oWaypoint = GetFirstObjectInArea(oArea);  int i;
    while (GetIsObjectValid(oWaypoint))
    {
        if (GetObjectType(oWaypoint) == OBJECT_TYPE_PLACEABLE && GetUseableFlag(oWaypoint))
        {
            i++;
            SetLocalObject(oArea, "p_"+IntToString(i), oWaypoint);              d(IntToString(i)+") "+GetName(oWaypoint));
        }

        oWaypoint = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, "p_spawned", i);
}

void CreateAreaTransitionsToAllAreas()
{
    object oTransitionTarget, oTransitionObject, oArea = GetFirstArea();
    object oSpawnPoint = GetWaypointByTag(ISL_MAPS_RESREF_PORTPLC);
    object areLocation = GetArea(oSpawnPoint);
    object oStartingArea = GetAreaFromLocation(GetStartingLocation());
    location locSpawnPoint = GetLocation(oSpawnPoint), locA, locB;
    vector vecSpawnpoint = GetPositionFromLocation(locSpawnPoint);
    float fX = (vecSpawnpoint.x), fY = (vecSpawnpoint.y);
    int h, w;

    while (GetIsObjectValid(oArea))
    {
        if (GetResRef(oArea) != GetResRef(oStartingArea))
        {
            w = GetAreaSize(AREA_WIDTH, oStartingArea)*10;                          PrintInteger(w);  PrintInteger(FloatToInt(fX));
            h = GetAreaSize(AREA_HEIGHT, oStartingArea)*10;                         PrintInteger(h);

            if (FloatToInt(fX) >= w)
            {
                fY = fY + ISL_MAPS_SPACER_PORTPLC;
                fX = ISL_MAPS_SPACER_PORTPLC;
            }

            else
                fX = fX + ISL_MAPS_SPACER_PORTPLC;

            locA = Location(areLocation, Vector(fX, fY, 0.0), 0.0);
            locB = GetValidLocationInArea(oArea);
            oTransitionObject = CreateObject(OBJECT_TYPE_PLACEABLE, ISL_MAPS_RESREF_PORTPLC, locA, FALSE, GetResRef(oArea));
            oTransitionTarget = CreateObject(OBJECT_TYPE_PLACEABLE, ISL_MAPS_RESREF_PORTPLC, locB, FALSE, GetResRef(oStartingArea));

            SetName(oTransitionObject, GetName(oArea) +" ("+ GetResRef(oArea)+")");
            SetName(oTransitionTarget, GetName(oStartingArea) + "("+GetResRef(oStartingArea)+")");

            if (dbg==1) SetDescription(oTransitionObject, "A: " + l(locA) + "\nB: " + l(locB));
        }

        oArea = GetNextArea();
    }

    SetLocalInt(oStartingArea, "spawned", 1);
}

void DoJumpToTarget(object oPC, location locJumpTo)
{
    AssignCommand(oPC, ClearAllActions(TRUE));
    AssignCommand(oPC, ActionJumpToLocation(locJumpTo));
}

void DoPortalUse(object oPC, object oPortal = OBJECT_SELF)
{
    object oTargetArea;
    location locTransitPlc;
    string sResRef = GetTag(oPortal);

    if (sResRef != "_start_")
    {
        oTargetArea = GetAreaByResRef(sResRef);                                 d("Starting Area, Target Area: "+GetName(oTargetArea));
        locTransitPlc = GetLocation(GetTransitionTargetInArea(oTargetArea));    d("Starting Area, Source Area: "+GetName(GetAreaFromLocation(locTransitPlc)));
        ExploreAreaForPlayer(oTargetArea, oPC, TRUE);                           d("Exploring Area for player");
    }
    else
        locTransitPlc = GetStartingLocation();                                  d("Not Starting Area, Target Area: "+GetName(GetAreaFromLocation(locTransitPlc)));

    DelayCommand(ISL_MAPS_CONFLOAT_DELAY, DoJumpToTarget(oPC, locTransitPlc));  d("Do jump.");
}

void CreateTools(object oPC)
{
    object oItem1 = GetItemPossessedBy(oPC, ISL_MAPS_RESREF_JMPTOOL);
    object oItem2 = GetItemPossessedBy(oPC, ISL_MAPS_RESREF_WPTTOOL);
    object oItem3 = GetItemPossessedBy(oPC, ISL_MAPS_RESREF_PLCTOOL);
    object oItem4 = GetItemPossessedBy(oPC, ISL_MAPS_RESREF_DORTOOL);

    if (!GetIsObjectValid(oItem1) &&
         GetIsPC(oPC) || GetIsDM(oPC) || GetIsDMPossessed(oPC))
        CreateItemOnObject(ISL_MAPS_RESREF_JMPTOOL, oPC);

    if (!GetIsObjectValid(oItem2) &&
         GetIsPC(oPC) || GetIsDM(oPC) || GetIsDMPossessed(oPC))
        CreateItemOnObject(ISL_MAPS_RESREF_WPTTOOL, oPC);

    if (!GetIsObjectValid(oItem3) &&
         GetIsPC(oPC) || GetIsDM(oPC) || GetIsDMPossessed(oPC))
        CreateItemOnObject(ISL_MAPS_RESREF_PLCTOOL, oPC);

    if (!GetIsObjectValid(oItem4) &&
         GetIsPC(oPC) || GetIsDM(oPC) || GetIsDMPossessed(oPC))
        CreateItemOnObject(ISL_MAPS_RESREF_DORTOOL, oPC);
}

