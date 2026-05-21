state("game")
{
    short finish: 0x166B418, 0x51058;
    short start: 0x166B418, 0x51071;
    long questflags: 0x166B418, 0x51074;
    short bossflags: 0x166B418, 0x5107D;
    short area: 0x166B418, 0x585EC;
    short room: 0x166B418, 0x585EF;
    byte control: 0x0115B498, 0x28, 0x8, 0x8, 0xD0;
    long framecounter: 0x0115B498, 0x28, 0x8, 0x8, 0x238;
}

init
{
    refreshRate = 120;
}

startup
{
    vars.starttime = 0;
    vars.in_random = false;
    Dictionary<int, int[]> randomized_areas = new Dictionary<int, int[]>() {
        {0, new int[]{}},
        {1, new int[]{7}},
        {2, new int[]{44}},
        {3, new int[]{34, 46}},
        {4, new int[]{20}},
        {5, new int[]{31}},
        {6, new int[]{35}},
        {7, new int[]{27}},
        {8, new int[]{27}},
        {9, new int[]{16}},
    };
    vars.randomized_areas = randomized_areas;
	settings.Add("area_change", true, "Split on warp");
	settings.Add("area_change_normal", false, "Split on normal warp.", "area_change");
	settings.Add("area_change_parlor", false, "Split on warp to parlor.", "area_change");
	settings.Add("upgrade_received", false, "Split on returning upgrade items.");
	settings.Add("random_area", true, "Split on randomized areas.");
	settings.Add("random_area_enter", false, "Split on entering randomized areas.", "random_area");
	settings.Add("random_area_exit", false, "Split on exiting randomized areas.", "random_area");
}

start
{
    if (current.start == 6 && current.control == 2 && old.control != 2)
    {
        vars.starttime = current.framecounter;
        return true;
    }
    return false;
}

update
{
    
}

split
{
    if (settings["area_change_normal"])
    {
        if (current.area != old.area && ((current.area != 0 && old.area != 0) || settings["area_change_parlor"]))
        {
            return true;
        }
    }
    if (current.room != old.room)
    {
        if (settings["random_area_enter"] && Array.Exists((int[])vars.randomized_areas[current.area], x => x == current.room))
        {
            return true;
        }
        if (settings["random_area_exit"] && Array.Exists((int[])vars.randomized_areas[current.area], x => x == old.room))
        {
            return true;
        }
    }
    if (settings["upgrade_received"])
    {
        if ((current.questflags & 0x492492) != (old.questflags & 0x492492))
        {
            return true;
        }
    }
    if ((current.bossflags & 0xFFE0) != (old.bossflags & 0xFFE0))
    {
        return true;
    }
    if (current.finish & 0x1 != 0 && current.finish != old.finish)
    {
        return true;
    }
    return false;
}

reset
{
    return current.framecounter < old.framecounter;
}

gameTime
{
    return TimeSpan.FromMilliseconds((current.framecounter - vars.starttime) * (1/120.0 * 1000));
}

isLoading
{
    return old.framecounter == current.framecounter;
}
