/*
 * mod-playerbots-bis — released under GNU GPL v2, matching mod-playerbots and
 * AzerothCore. Redistribute/modify under version 2 of the License, or (at your
 * option) any later version.
 *
 * The function name must be Addmod_playerbots_bisScripts() so AzerothCore's
 * generated module loader finds it: the name is derived from the module's
 * directory name, modules/mod-playerbots-bis, with hyphens turned into
 * underscores. Rename the directory and this entry point stops being called.
 */

void AddSC_playerbots_bis();

void Addmod_playerbots_bisScripts()
{
    AddSC_playerbots_bis();
}
