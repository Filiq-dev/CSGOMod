#include <amxmodx>
#include <csgomod>

#define PLUGIN "CS:GO Server Menu"
#define VERSION "2.0"
#define AUTHOR "O'Zone"

new Array:titles, Array:commands;

new const menuCommands[][] = { "say /menu", "say_team /menu", "menu", "say /komendy", "say_team /komendy",
	"say /pomoc", "say_team /pomoc", "say /commands", "say_team /commands", "say /help", "say_team /help" };

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof menuCommands; i++) register_clcmd(menuCommands[i], "server_menu");
}

public plugin_cfg()
{
	titles = ArrayCreate(64, 1);
	commands = ArrayCreate(64, 1);

	new filePath[128];

	get_localinfo("amxx_configsdir", filePath, charsmax(filePath));
	format(filePath, charsmax(filePath), "%s/csgo_menu.ini", filePath);

	if (!file_exists(filePath)) {
		new error[128];

		formatex(error, charsmax(error), "[CS:GO] Config file csgo_menu.ini has not been found in %s", filePath);

		set_fail_state(error);
	}

	new content[128], title[64], command[64], file = fopen(filePath, "r");

	while (!feof(file)) {
		fgets(file, content, charsmax(content)); trim(content);

		if(content[0] == ';' || content[0] == '^0') continue;

		parse(content, title, charsmax(title), command, charsmax(command));

		ArrayPushString(titles, title);
		ArrayPushString(commands, command);
	}

	fclose(file);
}

public client_putinserver(id)
{
	client_cmd(id, "bind ^"v^" ^"menu^"");
	cmd_execute(id, "bind v menu");
}

public server_menu(id)
{
	new title[64], menu;

	formatex(title, charsmax(title), "%L", id, "SERVER_MENU");
	menu = menu_create(title, "server_menu_handler");

	for (new i; i < ArraySize(titles); i++) {
		ArrayGetString(titles, i, title, charsmax(title));

		menu_additem(menu, title);
	}

	formatex(title, charsmax(title), "%L", id, "MENU_TITLE_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, title);

	formatex(title, charsmax(title), "%L", id, "MENU_TITLE_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, title);

	formatex(title, charsmax(title), "%L", id, "MENU_TITLE_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, title);

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public server_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT) {
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	new command[64];

	ArrayGetString(commands, item, command, charsmax(command));

	client_cmd(id, command);
	engclient_cmd(id, command);
	cmd_execute(id, command);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}
