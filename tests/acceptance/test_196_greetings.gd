extends GutTest
# Task 196: Greetings, little holiday greetings for the title screen.

const PATH := "res://scripts/core/greetings.gd"


func test_greetings() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var g = load(PATH)
	assert_eq(g.for_date(10, 31), "Happy Halloween!")
	assert_eq(g.for_date(12, 25), "Merry Christmas!")
	assert_eq(g.for_date(1, 1), "Happy New Year!")
	assert_eq(g.for_date(3, 14), "Happy Pi Day! Can you fly 314 m?")
	assert_eq(g.for_date(6, 9), "", "ordinary days have none")
	assert_eq(g.DATES.size(), 7)
	var date := Time.get_date_dict_from_system()
	assert_eq(g.today(), g.for_date(int(date["month"]), int(date["day"])))
