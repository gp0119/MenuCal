import argparse
import json
from datetime import date, datetime
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.request import urlopen
from zoneinfo import ZoneInfo


SOURCE = "https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/{year}.json"
RESOURCE = Path(__file__).resolve().parents[1] / "MenuCal/Resources/PublicHolidays.json"


def download_holidays(year):
    with urlopen(SOURCE.format(year=year), timeout=20) as response:
        notice = json.load(response)

    if not isinstance(notice, dict) or notice.get("year") != year:
        raise ValueError("上游数据的公告年份不匹配")
    days = notice.get("days")
    if not isinstance(days, list) or not days:
        raise ValueError("上游数据缺少节假日记录")

    holidays = {}
    # 公告年份可能与日期年份不同，例如跨年元旦假期。
    for day in days:
        if not isinstance(day, dict):
            raise ValueError("上游数据包含无效的节假日记录")
        day_date = day.get("date")
        is_off_day = day.get("isOffDay")
        if not isinstance(day_date, str) or not isinstance(is_off_day, bool):
            raise ValueError("上游记录需要日期字符串和 isOffDay 布尔值")
        if date.fromisoformat(day_date).isoformat() != day_date:
            raise ValueError(f"日期应使用 YYYY-MM-DD 格式：{day_date}")
        holidays[day_date.replace("-", "")] = "holiday" if is_off_day else "workday"

    return holidays


def main():
    parser = argparse.ArgumentParser(description="从 holiday-cn 更新 MenuCal 节假日数据")
    parser.add_argument("year", nargs="?", type=int, help="公告年份，默认按北京时间取下一年")
    args = parser.parse_args()
    year = args.year if args.year is not None else datetime.now(ZoneInfo("Asia/Shanghai")).year + 1
    if not 1 <= year <= 9999:
        parser.error("公告年份须在 1 到 9999 之间")

    try:
        holidays = download_holidays(year)
        current = json.loads(RESOURCE.read_text(encoding="utf-8"))
        if not isinstance(current, dict):
            raise ValueError(f"{RESOURCE.name} 必须是日期到节假日类型的 JSON 对象")
        updated = {**current, **holidays}
        if updated == current:
            print(f"{year} 年公告中的节假日记录已全部导入")
            return

        with TemporaryDirectory(dir=RESOURCE.parent) as directory:
            temporary = Path(directory) / RESOURCE.name
            temporary.write_text(json.dumps(updated, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            temporary.replace(RESOURCE)
    except (OSError, ValueError) as error:
        parser.exit(1, f"导入 {year} 年节假日数据失败：{error}\n")

    print(f"已导入 {year} 年公告中的 {len(holidays)} 条放假和调休上班记录")


if __name__ == "__main__":
    main()
