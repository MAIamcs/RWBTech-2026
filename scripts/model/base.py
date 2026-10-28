import psycopg2
import psycopg2.sql as sql
import os
import json
import csv
import decimal
from pathlib import Path

BASE = Path(__file__).resolve().parent
REPORT = BASE / 'answers'
REPORT.mkdir(exist_ok=True, parents=True)
REPORT2 = BASE / 'tables_info'
REPORT2.mkdir(exist_ok=True, parents=True)

conn = psycopg2.connect(
    os.environ.get(
        'DATABASE_URL',
        'postgresql://hack:hack@localhost:5432/marketplace'
    )
)
conn.autocommit = True

checks = []
def check(name, actual, expected):
    checks.append({
        "check": name,
        "actual": actual,
        "expected": expected,
        "passed": actual == expected
    })


def make_request(q, args=None):
    with conn.cursor() as c:
        c.execute(q, args)
        return c.fetchall() if c.description else []


def save(name, data, REP=REPORT):
    pa = REP / name
    pa.write_text(
        json.dumps(data, ensure_ascii=False, indent=2, default=str) + '\n'
    )


def main():
    profile = {}

    tables = make_request("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw' AND table_type = 'BASE TABLE'
    """
                          )

    for (table,) in tables:
        columns = make_request("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'raw' AND table_name = %s
        """, (table,))

        profile[table] = {
            "rows": make_request(
                f'SELECT COUNT(*) FROM raw."{table}"'
            )[0][0],
            "missing": {}
        }

        for (column,) in columns:
            if not column.startswith("_"):
                profile[table]["missing"][column] = make_request(
                    f'SELECT COUNT(*) FROM raw."{table}" '
                    f'WHERE "{column}" IS NULL OR "{column}"::text = \'\''
                )[0][0]

    save("sql_profile.json", profile, REPORT2)

    path_to_build = BASE / 'build.sql'
    build = '\n'.join(
        line for line in path_to_build.read_text().splitlines() if not line.startswith('\\')
    )
    make_request(build)

    for table, data in profile.items():
        check(
            f"row_count_{table}",
            make_request(
                f'SELECT COUNT(*) FROM core."{table}"'
            )[0][0],
            data["rows"]
        )

    check("order_summary_unique",
        make_request("SELECT COUNT(*) = COUNT(DISTINCT order_id) FROM mart.order_summary")[0][0], True)

    check("months",
          make_request("SELECT COUNT(*) FROM mart.ans1")[0][0], 24)

    check("zero_revenue_months",
          make_request("SELECT COUNT(*) FROM mart.ans1 WHERE revenue = 0")[0][0], 1)

    check("monthly_revenue",
          make_request("SELECT SUM(revenue) FROM mart.ans1")[0][0], decimal.Decimal("13221498.11"))

    check("top_seller",
          make_request("SELECT MAX(revenue) FROM mart.ans2")[0][0], decimal.Decimal("226987.93"))

    check("average_order_value",
          make_request("SELECT average_order_value FROM mart.ans3")[0][0], decimal.Decimal("159.88"))

    check("buyers",
          make_request("SELECT buyers FROM mart.ans4")[0][0], 96096)

    check("repeat_percent",
          make_request("SELECT repeat_percent FROM mart.ans4")[0][0], decimal.Decimal("3.12"))

    check("categories",
          make_request("SELECT COUNT(*) FROM mart.ans5")[0][0], 74)

    check("top_category",
          make_request("SELECT MAX(revenue) FROM mart.ans5")[0][0], decimal.Decimal("1233131.72"))

    check("category_revenue",
          make_request("SELECT SUM(revenue) FROM mart.ans5")[0][0], decimal.Decimal("13221498.11"))

    exports = {
        "ans1": "month",
        "ans2": "revenue DESC, seller_id LIMIT 10",
        "ans3": "1",
        "ans4": "1",
        "ans5": "revenue DESC, category_key",
        "data_quality": "issue"
    }

    for table, order in exports.items():
        with conn.cursor() as c:
            c.execute(f"SELECT * FROM mart.{table} ORDER BY {order}")
            with (REPORT / f"{table}.csv").open("w", newline="", encoding="utf-8") as file:
                writer = csv.writer(file)
                writer.writerow([col.name for col in c.description])
                writer.writerows(c.fetchall())

    save("checks.json", checks, REPORT2)

    for item in checks:
        print(("PASS " if item["passed"] else "FAIL") + item["check"])

    if any(not item["passed"] for item in checks):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
    conn.close()