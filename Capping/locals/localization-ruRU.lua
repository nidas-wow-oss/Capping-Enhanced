if GetLocale() ~= "ruRU" then return end

CappingLocale:CreateLocaleTable({

	["Alterac Valley"] = "Альтеракская долина",
	["Arathi Basin"] = "Низина Арати",
	["Warsong Gulch"] = "Ущелье Песни Войны",
	["Eye of the Storm"] = "Око Бури",
	["Wintergrasp"] = "Озеро Ледяных Оков",

	["Auto Quest Turnins"] = "Авто сдача квестов",
	["Bar"] = "Полоса",
	["Width"] = "Ширина",
	["Height"] = "Высота",
	["Texture"] = "Текстура",
	["Map Scale"] = "Масштаб карты",
	["Hide Border"] = "Скрыть кромку",
	["Port Timer"] = "Время телепортации",
	["Wait Timer"] = "Время ожидания",
	["Show/Hide Anchor"] = "Показать/скрыть якорёк",
	["Narrow Map Mode"] = "Обрезанная карта",

	["Test"] = "Тест",
	["Flip Growth"] = "Перевернуть",

	["Move Scoreboard"] = "Переместить табло",
	["Spacing"] = "Расстояние",
	["Request Sync"] = "Запросить синхронизацию",
	["Fill Grow"] = "Заполнять выростая",
	["Fill Right"] = "Заполнять направо",
	["Font"] = "Шрифт",
	["Time Position"] = "Расположение времени",
	["Border Width"] = "Ширина кромки",
	["Send to BG"] = "Писать в BG",
	["Send to SAY"] = "Писать в SAY",
	["Cancel Timer"] = "Отменить Таймер",
	["Move Capture Bar"] = "Переместить Таймер Захвата",

	["Port: %s"] = "На БГ: %s",
	["Queue: %s"] = "Очередь: %s",
	["Battle Begins"] = "Начало сражения",
	["1 minute"] = "1 минута",
	["60 seconds"] = "60 секунд",
	["30 seconds"] = "30 секунд",
	["15 seconds"] = "15 секунд",
	["One minute until"] = "Одна минута до",

	["Thirty seconds until"] = "через 30 секунд",
	["Fifteen seconds until"] = "Пятнадцать секунд до",

	["%s: %s - %d:%02d"] = "%s: %s - через %d:%02d",

	["Bases: (%d+)  Resources: (%d+)/(%d+)"] = "Базы: (%d+) Ресурсы: (%d+)/(%d+)",
	["has assaulted"] = "штурмует",
	["claims the"] = "через ([1]?%s?)минуту",
	["has taken the"] = "захватил",
	["has defended the"] = "отразил",
	["Final: %d - %d"] = "Финал: %d - %d",
	["wins %d-%d"] = "выиграет %d-%d",

	["was picked up by (.+)!"] = "(.+) несет флаг Орды!",
	["was picked up by (.+)!2"] = "Флаг Альянса у (.+)!",
	["dropped"] = "уронил",
	["captured the"] = "захватил",
	["Flag respawns"] = "Появление Флагов",
	["%s's flag carrier: %s (%s)"] = "%s Флагоносец: %s (%s)",

	["Smith Regzar"] = "Кузнец Регзар",
	["Murgot Deepforge"] = "Мургот Подземная Кузня",
	["Primalist Thurloga"] = "Старейшина Турлога",
	["Arch Druid Renferal"] = "Верховный друид Дикая Лань",
	["Stormpike Ram Rider Commander"] = "Командир наездников на баранах из клана Грозовой Вершины",
	["Frostwolf Wolf Rider Commander"] = "Командир наездников на волках из клана Северного Волка",

	["^(.+) has taken the flag!"] = "^(.+) захватывает флаг!",
	["Bases: (%d+)  Victory Points: (%d+)/(%d+)"] = "Базы: (%d+)  Очки победы: (%d+)/(%d+)",

})
