local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local DocumentRegistry = require("document/documentregistry")
local BookList = require("ui/widget/booklist")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local ReaderUI = require("apps/reader/readerui")
local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")
local InputDialog = require("ui/widget/inputdialog")
local Screen = require("device").screen
local _ = require("gettext")

local grep_search = WidgetContainer:extend {
    name = "grep_search",
    is_doc_only = false,
}

grep_search.query = ""
function grep_search:onDispatcherRegisterActions()
    Dispatcher:registerAction("launch_organiser",
        { category = "none", event = "organiser_trigger", title = _("grep_search"), general = true, })
end

function grep_search:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function grep_search:addToMainMenu(menu_items)
    menu_items.organise = {
        text = _("grep_search"),
        sorting_hint = "search",
        callback = function()
            self.input_search_term(self)
        end,
    }
end

function grep_search:input_search_term()
    local dialog
    dialog = InputDialog:new {
        title = _("Grep"),
        input_hint = _("put you search term here"),
        buttons = {
            {
                {
                    text = _("Cancel"),
                    id = "close",
                    callback = function()
                        UIManager:close(dialog)
                    end,
                },
                {
                    text = _("Search"),
                    id = "search",
                    is_enter_default = true,
                    callback = function()
                        self.query = dialog:getInputText()
                        UIManager:close(dialog)

                        local fc = self.ui.file_chooser
                        if fc then
                            self:start_grep(fc.path)

                            UIManager:show(InfoMessage:new {
                                text = _("grep: ") .. self.query .. _(", path: ") .. fc.path,
                                timeout = 5,
                            })
                        else
                            logger.dbg("input_search_term: Failed fetchinf file_chooser")
                        end
                    end
                }
            }
        }
    }
    UIManager:show(dialog)
    dialog:onShowKeyboard()
end

local function basename(path)
    return path:match("([^/\\]+)$") or path
end

function grep_search:start_grep(path)
    local ignore_case = self.query:lower() == self.query
    local grep_flag = ignore_case and "-qi" or "-q"

    local command = string.format([[
    find %q -type f -name '*.epub' -exec sh -c '
        for f; do
            unzip -p "$f" | grep %s %q && echo "$f"
        done
    ' _ {} + ]], path, grep_flag, self.query)

    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    local item_table = {}
    for file in result:gmatch("[^\r\n]+") do
        table.insert(item_table, {
            text = basename(file),
            path = file,
            query = self.query,
            is_file = true,
        })
    end

    if #item_table == 0 then
        UIManager:show(InfoMessage:new { text = _("No results found.") })
        return
    end

    local menu = BookList:new {
        name = "grep_results",
        title = _("Grep Results"),
        item_table = item_table,
        onMenuSelect = self.onMenuSelect,
        close_callback = function()
            UIManager:close(menu)
        end,
    }

    UIManager:show(menu)
end

function grep_search:onMenuSelect(item)
    if not item.is_file or not lfs.attributes(item.path) then return end

    if DocumentRegistry:hasProvider(item.path, nil, true) then
        local readerui = ReaderUI:new {
            dimen = Screen:getSize(),
            document = DocumentRegistry:openDocument(item.path),
        }

        UIManager:show(readerui)
        readerui.search:onShowFulltextSearchInput(item.query)
    end
end

return grep_search
