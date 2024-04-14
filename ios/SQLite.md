# SQLite

## SQLite close

클로으즈 옵션에 v2 가있는데
어노테이션이 macOS 10.10버전 이상만 사용 가능하게 되어있다 참고하자

```objc
public func sqlite3_close(_: OpaquePointer!) -> Int32

@available(macOS 10.10, *)
public func sqlite3_close_v2(_: OpaquePointer!) -> Int32

```

## SQLite 실행

```objc

public func sqlite3_exec(_: OpaquePointer!, _ sql: UnsafePointer<CChar>!, _ callback: (@convention(c) (UnsafeMutableRawPointer?, Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32)!, _: UnsafeMutableRawPointer!, _ errmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32

```

실행하는 방법이 적혀있다

```objc
** ^The sqlite3_exec() interface runs zero or more UTF-8 encoded,
** semicolon-separate SQL statements passed into its 2nd argument,
** in the context of the [database connection] passed in as its 1st
** argument.  ^If the callback function of the 3rd argument to
** sqlite3_exec() is not NULL, then it is invoked for each result row
** coming out of the evaluated SQL statements.  ^The 4th argument to
** sqlite3_exec() is relayed through to the 1st argument of each
** callback invocation.  ^If the callback pointer to sqlite3_exec()
** is NULL, then no callback is ever invoked and result rows are
** ignored.
```

해석해보면

```txt
db: 데이터베이스 연결 객체
zSql: 실행할 SQL 문장 문자열 (UTF-8 인코딩, 세미콜론(;)으로 구분된 여러 문장 가능)
callback: 콜백 함수 (NULL일 수 있음)
콜백 함수는 실행된 SQL 문장의 각 결과 행에 대해 호출됩니다.
콜백 함수의 첫 번째 인자는 pvUserData 인자로 전달된 데이터입니다.
콜백 함수의 두 번째 인자는 결과 행의 열 개수입니다.
콜백 함수의 세 번째 인자는 각 열에 대한 문자열 포인터 배열입니다.
콜백 함수의 네 번째 인자는 각 열 이름에 대한 문자열 포인터 배열입니다.
콜백 함수가 0이 아닌 값을 반환하면 sqlite3_exec() 함수는 실행을 중단하고 SQLITE_ABORT 에러를 반환합니다.
pvUserData: 콜백 함수에 전달될 사용자 데이터 (NULL일 수 있음)
errmsg: 에러 메시지 저장 위치 (NULL일 수 있음)
오류가 발생하면 에러 메시지가 이 메모리에 저장됩니다.
반환된 에러 메시지 메모리는 sqlite3_malloc() 함수를 통해 할당되었으므로, 더 이상 필요 없으면 sqlite3_free() 함수를 호출하여 해제해야 메모리 누수를 방지할 수 있습니다.
```

주석에 좀중요한 내용들이 적혀있는데

또 사용법을 보면

```txt
sqlite3_exec() 함수는 SQLite 명령어 실행을 위한 편의 함수입니다.
이 함수는 다음 세 개의 개별 함수를 캡슐화합니다:
sqlite3_prepare_v2(): SQL 문장을 파싱하고 실행 계획을 만듭니다.
sqlite3_step(): 준비된 SQL 문장을 실행합니다.
sqlite3_finalize(): 준비된 SQL 문장을 해제합니다.
sqlite3_exec() 함수를 사용하면 많은 C 코드를 작성하지 않고도 여러 SQL 문장을 연속적으로 실행할 수 있습니다.
```

이것들을 한곳에 모아 놓은 거같다

```objc
C
const char *sql = "SELECT * FROM table1; UPDATE table2 SET name = 'newValue';";
char *errmsg;
int rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);

if ( rc != SQLITE_OK ) {
  fprintf(stderr, "Error executing SQL: %s\n", errmsg);
  sqlite3_free(errmsg);
} else {
  // 성공 처리
}
```

### SQLite VFS 가상화

public struct sqlite3_vfs

라는 함수가 있는데 가상으로 따로 만들 수 있나보다

### SQLite Max memory

```SQLITE_CONFIG_MEMDB_MAXSIZE``` 에 기본적으로 1GB의 메모리를 할당해준다고 한다

### SQLite busy

```objc
public func sqlite3_busy_timeout(_: OpaquePointer!, _ ms: Int32) -> Int32
```

테이블이 잠겨있을때 일정시간이 누적되면 콜백을 해주는 함수 이다.

### SQLite get table

```objc
public func sqlite3_get_table(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ pazResult: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?>!, _ pnRow: UnsafeMutablePointer<Int32>!, _ pnColumn: UnsafeMutablePointer<Int32>!, _ pzErrmsg: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!) -> Int32

```

테이블을 집접 적으로 사용할 수 있는 방법인거 같다

하지만 맥에서는 집접 사용하는 것을 권장하지 않고

```sqlite3_prepare_v2``` 와같은 함수로 사용하는 것을 권장한다.

호출을 하였을 경우

```md
Name  | Age
-------|----
Alice  | 43
Bob    | 28
Cindy  | 21
```

위의 테이블이 아래의 대이터 형식으로 담긴다고 한다

```objc
azResult[0] = "Name";
azResult[1] = "Age";
azResult[2] = "Alice";
azResult[3] = "43";
azResult[4] = "Bob";
azResult[5] = "28";
azResult[6] = "Cindy";
azResult[7] = "21";
```

함께 사용하는 코드는 아래와 같다

```objc
public func sqlite3_free_table(_ result: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>!)

public func sqlite3_vmprintf(_: UnsafePointer<CChar>!, _: CVaListPointer) -> UnsafeMutablePointer<CChar>!

@available(macOS 10.7, *)
public func sqlite3_vsnprintf(_: Int32, _: UnsafeMutablePointer<CChar>!, _: UnsafePointer<CChar>!, _: CVaListPointer) -> UnsafeMutablePointer<CChar>!
```

> [!WARNING]
> ```free```할때도 ```sqlite3_free``` 로 메모리 해제되는것이 아닌 ```sqlite3_free_table```  함수를 사용하여 해제 해야하는거 같다

### SQLite Memory

```objc
public func sqlite3_malloc(_: Int32) -> UnsafeMutableRawPointer!

@available(macOS 10.11, *)
public func sqlite3_malloc64(_: sqlite3_uint64) -> UnsafeMutableRawPointer!

public func sqlite3_realloc(_: UnsafeMutableRawPointer!, _: Int32) -> UnsafeMutableRawPointer!

@available(macOS 10.11, *)
public func sqlite3_realloc64(_: UnsafeMutableRawPointer!, _: sqlite3_uint64) -> UnsafeMutableRawPointer!

public func sqlite3_free(_: UnsafeMutableRawPointer!)

@available(macOS 10.11, *)
public func sqlite3_msize(_: UnsafeMutableRawPointer!) -> sqlite3_uint64
```

상위 코드는 메모리를 집접 관리하게 되는 함수들이다

> [!WARRING]
> 이함수는 집접적인 메모리 할당으로 ```free```를 잘 해주어야 한다
> 메모리를 해제하지 않으면 심각한 문제를 이르킬 수 있음

이러한 메모리 사용량을 확인할 수도 있다

```objc
public func sqlite3_memory_used() -> sqlite3_int64
public func sqlite3_memory_highwater(_ resetFlag: Int32) -> sqlite3_int64
```

### SQLite 관리자

```objc
public func sqlite3_set_authorizer(_: OpaquePointer!, _ xAuth: (@convention(c) (UnsafeMutableRawPointer?, Int32, UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?) -> Int32)!, _ pUserData: UnsafeMutableRawPointer!) -> Int32
```

신뢰할 수 없는 소스를 입력받아 sql를 실행 시켰을때 접근을 제한함

사용방법은 모르겠다...

하지만 읽기는 가능하지만 수정 과 같은 동작은 제한 설정을 할 수 있다고 한다

|Constant Name | Action | 3rd Argument | 4th Argument|
|:--|:--|:--|:--|
| SQLITE_CREATE_INDEX | Create an index | Index Name | Table Name |
| SQLITE_CREATE_TABLE | Create a table | Table Name | NULL |
| SQLITE_CREATE_TEMP_INDEX | Create a temporary index | Index Name | Table Name |
| SQLITE_CREATE_TEMP_TABLE | Create a temporary table | Table Name | NULL |
| SQLITE_CREATE_TEMP_TRIGGER | Create a temporary trigger | Trigger Name | Table N ame |
| SQLITE_CREATE_TEMP_VIEW | Create a temporary view | View Name | NULL |
| SQLITE_CREATE_TRIGGER | Create a trigger | Trigger Name | Table Name |
| SQLITE_CREATE_VIEW | Create a view | View Name | NULL |
| SQLITE_DELETE | Delete data from a table | Table Name | NULL |
| SQLITE_DROP_INDEX | Drop an index | Index Name | Table Name |
| SQLITE_DROP_TABLE | Drop a table | Table Name | NULL |
| SQLITE_DROP_TEMP_INDEX | Drop a temporary index | Index Name | Table Name |
| SQLITE_DROP_TEMP_TABLE | Drop a temporary table | Table Name | NULL |
| SQLITE_DROP_TEMP_TRIGGER | Drop a temporary trigger | Trigger Name | Table Name |
| SQLITE_DROP_TEMP_VIEW | Drop a temporary view | View Name | NULL |
| SQLITE_DROP_TRIGGER | Drop a trigger | Trigger Name | Table Name |
| SQLITE_DROP_VIEW | Drop a view | View Name | NULL |
| SQLITE_INSERT | Insert data into a table | Table Name | NULL |
| SQLITE_PRAGMA | Execute a PRAGMA statement | Pragma Name | First Argument (or N ULL) |
| SQLITE_READ | Read data from a table | Table Name | Column Name |
| SQLITE_SELECT | Execute a SELECT statement | NULL | NULL |
| SQLITE_TRANSACTION | Start or end a transaction | Operation | NULL |
| SQLITE_UPDATE | Update data in a table | Table Name | Column Name |
| SQLITE_ATTACH | Attach a database | Filename | NULL |
| SQLITE_DETACH | Detach a database | Database Name | NULL |
| SQLITE_ALTER_TABLE | Alter the structure of a table | Database Name | Table Name |
| SQLITE_REINDEX | Re-create an index | Index Name | NULL |
| SQLITE_ANALYZE | Analyze a table for optimization | Table Name | NULL |
| SQLITE_CREATE_VTABLE | Create a virtual table (not commonly used) | Table Name | Module Name |
| SQLITE_DROP_VTABLE | Drop a virtual table (not commonly used) | Table Name |  Module Name |
| SQLITE_FUNCTION | (no longer used) | NULL | Function Name |
| SQLITE_SAVEPOINT | Create or release a savepoint within a transaction |  Operation | Savepoint Name |
| SQLITE_COPY | (no longer used) | N/A | N/A |
| SQLITE_RECURSIVE | (reserved for future use) | NULL | NULL |

### SQLite Open

```objc
public func sqlite3_open(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32

/* Database filename (UTF-8) */
/* OUT: SQLite db handle */

public func sqlite3_open16(_ filename: UnsafeRawPointer!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32

/* Database filename (UTF-16) */
/* OUT: SQLite db handle */

public func sqlite3_open_v2(_ filename: UnsafePointer<CChar>!, _ ppDb: UnsafeMutablePointer<OpaquePointer?>!, _ flags: Int32, _ zVfs: UnsafePointer<CChar>!) -> Int32

/* Database filename (UTF-8) */
/* OUT: SQLite db handle */
/* Flags */
/* Name of VFS module to use */

```

이함수는 db 파일을 읽고 가져오는 것을 해준다

> [!NOTE]
> URI 파일 이름이란?\
> URI(Uniform Resource Identifier)는 자원을 식별하는 데 사용되는 표준 형식입니다. SQLite에서는 데이터베이스 파일에 대한 URI를 사용하여 파일 위치를 지정할 수 있습니다.

URI 파일 이름 사용 조건

URI 파일 이름 해석 기능이 활성화되어 있어야 합니다. ( SQLITE_OPEN_URI 플래그 설정, sqlite3_config() 또는 컴파일 타임 옵션)
파일 이름은 "file:"로 시작해야 합니다.
URI 구조

URI은 다음과 같은 형식으로 구성됩니다.

```txt
file://<authority>/<path>#<fragment>

## example
## file:data.db: 현재 디렉터리에 있는 "data.db" 파일을 엽니다.
## file:/home/fred/data.db: "/home/fred/data.db" 데이터베이스 파일을 엽니다.
## file:data.db?mode=ro&cache=private: "data.db"를 읽기 전용 모드로 개인 캐시와 함께 엽니다.

```

authority: (옵션) 호스트 이름과 포트 번호 (SQLite에서는 "localhost"만 허용)
path: 데이터베이스 파일의 경로 (절대 경로 또는 상대 경로)
fragment: (옵션) 무시됨

SQLite에서의 URI 해석

SQLite는 RFC 3986에 따라 URI를 파싱합니다.
authority 부분은 비어있거나 "localhost"만 허용됩니다. 다른 값을 사용하면 오류가 반환됩니다.
fragment 부분은 무시됩니다.

> [!WARNING]
> sqlite3_open() 또는 sqlite3_open_v2() 함수를 호출하기 전에 반드시 임시 디렉터리를 설정해야 합니다.\
> 이렇게 하지 않으면 임시 파일을 사용하는 여러 기능이 작동하지 않을 수 있습니다.

임시 디렉터리란?

SQLite는 데이터베이스 작업을 수행하는 동안 내부적으로 임시 파일을 사용할 수 있습니다. 예를 들어 복잡한 쿼리 실행이나 복구 작업 시에 임시 파일이 필요할 수 있습니다.

```sqlite3_temp_directory()``` 함수를 사용하여 폴더를 지정할 수 있습니다.

```ojbc
const char* temp_dir = "/path/to/your/temporary/directory";
sqlite3_temp_directory(temp_dir);
// 이제 sqlite3_open() 또는 sqlite3_open_v2()를 호출할 수 있습니다.
```

### SQLite Prepared Statement

```objc

public func sqlite3_prepare(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-8 encoded */
/* Maximum length of zSql in bytes. */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */

public func sqlite3_prepare_v2(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-8 encoded */
/* Maximum length of zSql in bytes. */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */

@available(macOS 10.14, *)
public func sqlite3_prepare_v3(_ db: OpaquePointer!, _ zSql: UnsafePointer<CChar>!, _ nByte: Int32, _ prepFlags: UInt32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafePointer<CChar>?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-8 encoded */
/* Maximum length of zSql in bytes. */
/* Zero or more SQLITE_PREPARE_ flags */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */

public func sqlite3_prepare16(_ db: OpaquePointer!, _ zSql: UnsafeRawPointer!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafeRawPointer?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-16 encoded */
/* Maximum length of zSql in bytes. */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */

public func sqlite3_prepare16_v2(_ db: OpaquePointer!, _ zSql: UnsafeRawPointer!, _ nByte: Int32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafeRawPointer?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-16 encoded */
/* Maximum length of zSql in bytes. */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */

@available(macOS 10.14, *)
public func sqlite3_prepare16_v3(_ db: OpaquePointer!, _ zSql: UnsafeRawPointer!, _ nByte: Int32, _ prepFlags: UInt32, _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!, _ pzTail: UnsafeMutablePointer<UnsafeRawPointer?>!) -> Int32

/* Database handle */
/* SQL statement, UTF-16 encoded */
/* Maximum length of zSql in bytes. */
/* Zero or more SQLITE_PREPARE_ flags */
/* OUT: Statement handle */
/* OUT: Pointer to unused portion of zSql */
```

1. SQLite Prepared Statement란 무엇인가?

SQLite prepared statement는 SQL 문장을 미리 컴파일하고 저장하는 메커니즘입니다. 이를 통해 다음과 같은 장점을 얻을 수 있습니다.

성능 향상: 컴파일된 prepared statement는 실행할 때마다 다시 컴파일될 필요가 없으므로 성능이 향상됩니다.
오류 감소: 컴파일 과정에서 문법 오류를 감지할 수 있으므로 오류 발생 가능성이 줄어듭니다.
보안 강화: SQL 문장을 문자열 형태로 저장하지 않으므로 SQL 주입 공격에 대한 취약성이 감소합니다.
2. SQLite Prepared Statement 함수

SQLite에서는 여러 가지 prepared statement 함수를 제공합니다. 가장 일반적으로 사용되는 함수는 다음과 같습니다.

sqlite3_prepare(): UTF-8 인코딩된 SQL 문장을 컴파일합니다.
sqlite3_prepare_v2(): UTF-8 인코딩된 SQL 문장을 컴파일하고 추가 기능을 제공합니다.
sqlite3_prepare_v3(): UTF-8 인코딩된 SQL 문장을 컴파일하고 prepFlags 매개 변수를 사용하여 추가 기능을 제공합니다.
sqlite3_prepare16(): UTF-16 인코딩된 SQL 문장을 컴파일합니다.
sqlite3_prepare16_v2(): UTF-16 인코딩된 SQL 문장을 컴파일하고 추가 기능을 제공합니다.
sqlite3_prepare16_v3(): UTF-16 인코딩된 SQL 문장을 컴파일하고 prepFlags 매개 변수를 사용하여 추가 기능을 제공합니다.
3. Prepared Statement 함수 공통 인수

모든 prepared statement 함수는 다음과 같은 공통 인수를 사용합니다.

db: 이전에 성공적으로 호출된 sqlite3_open(), sqlite3_open_v2(), 또는 sqlite3_open16() 함수를 통해 얻은 데이터베이스 연결입니다.
zSql: 컴파일할 SQL 문장입니다. UTF-8 또는 UTF-16 인코딩되어야 합니다.
nByte: 선택적 인수입니다. 음의 값이면 zSql을 첫 번째 NULL 종료자까지 읽습니다. 양의 값이면 zSql에서 지정된 바이트 수를 읽습니다. 0 값이면 컴파일된 prepared statement가 생성되지 않습니다.
pzTail: 선택적 출력 인수입니다. 함수가 성공적으로 반환되면 *pzTail은 zSql 내에서 컴파일된 첫 번째 SQL 문장 다음 바이트의 첫 번째 위치를 가리킵니다.
4. prepFlags 매개 변수 (sqlite3_prepare_v3()만 해당)

sqlite3_prepare_v3() 함수는 prepFlags 매개 변수를 추가로 지원합니다. 이 매개 변수는 비트 배열이며 다음과 같은 플래그를 포함할 수 있습니다.

SQLITE_PREPARE_SINGLE: SELECT 문장만 허용합니다.
SQLITE_PREPARE_NO_AUTOINDEX: 자동 인덱싱을 비활성화합니다.
SQLITE_PREPARE_FULLCOLUMNNAMES: SELECT 문장의 모든 열 이름을 포함하도록 합니다.
SQLITE_PREPARE_IGNOREORDER: ORDER BY 절의 순서를 무시합니다.

### SQLite Bind

```objc
sqlite3_bind**
```

1. SQLite Prepared Statement에서 매개 변수 사용

SQLite prepared statement는 SQL 문장 내에 특수 문자를 사용하여 매개 변수를 정의할 수 있습니다. 이러한 매개 변수는 나중에 실제 값으로 대체됩니다.
사용할 수 있는 매개 변수 템플릿은 다음과 같습니다.
?: 이름이 없는 매개 변수 (왼쪽부터 순서대로 인덱스 부여)
?NNN: 이름이 없는 매개 변수, 뒤에 정수 NNN을 붙여 인덱스 명시 (NNN은 1 이상 SQLITE_LIMIT_VARIABLE_NUMBER 이하)
:VVV: 이름이 있는 매개 변수, VVV는 알파벳 숫자로 구성된 식별자
@VVV: 이름이 있는 매개 변수 (덜 일반적)
$VVV: 이름이 있는 매개 변수 (SQLite 확장)
2. 매개 변수 값 바인딩

prepared statement에 정의된 매개 변수에 실제 값을 할당하는 작업을 바인딩이라고 합니다.
SQLite는 sqlite3_bind_*() 함수 시리즈를 제공하여 이러한 바인딩 작업을 수행합니다.
sqlite3_bind_*() 함수의 첫 번째 인수는 prepared statement 객체 (sqlite3_stmt)를, 두 번째 인수는 바인딩할 매개 변수의 인덱스를 받습니다.
세 번째 인수는 바인딩할 실제 값이며, 그 타입은 호출하는 함수에 따라 다릅니다.
sqlite3_bind_text(): 문자열 (UTF-8 인코딩)
sqlite3_bind_text16(): 문자열 (UTF-16 인코딩)
sqlite3_bind_blob(): BLOB (Binary Large Object, 이진 데이터)
네 번째 인수는 선택적이며, 바인딩할 값의 길이 (바이트 수)를 지정합니다.
3. 문자열 바인딩 시 주의 사항

sqlite3_bind_text()과 sqlite3_bind_text16()은 각각 유효한 UTF-8 및 UTF-16 인코딩된 문자열만 전달해야 합니다.
sqlite3_bind_text64()는 여섯 번째 인수 (SQLITE_UTF8 또는 그 외)에 따라 UTF-8 또는 UTF-16 인코딩된 유니코드 문자열을 전달해야 합니다.
문자열 내에 null 문자가 포함되어 있으면 결과 문자열에 문제를 일으킬 수 있으므로 주의해야 합니다.

### SQLite column data

```objc
public func sqlite3_column_count(_ pStmt: OpaquePointer!) -> Int32
public func sqlite3_data_count(_ pStmt: OpaquePointer!) -> Int32
```

컬럼의 갯수를 알려주는거 같다

상위 두 코드의 차이점은 테이블에 모든 데이터를 가져오는 것과 가저온 데이터의 갯수를 가져오는 차이인거 같다

```objc
public func sqlite3_column_name(_: OpaquePointer!, _ N: Int32) -> UnsafePointer<CChar>!
public func sqlite3_column_name16(_: OpaquePointer!, _ N: Int32) -> UnsafeRawPointer!

public func sqlite3_column_database_name(_: OpaquePointer!, _: Int32) -> UnsafePointer<CChar>!
public func sqlite3_column_database_name16(_: OpaquePointer!, _: Int32) -> UnsafeRawPointer!
public func sqlite3_column_table_name(_: OpaquePointer!, _: Int32) -> UnsafePointer<CChar>!
public func sqlite3_column_table_name16(_: OpaquePointer!, _: Int32) -> UnsafeRawPointer!
public func sqlite3_column_origin_name(_: OpaquePointer!, _: Int32) -> UnsafePointer<CChar>!
public func sqlite3_column_origin_name16(_: OpaquePointer!, _: Int32) -> UnsafeRawPointer!
```

다양한 컬럼에 따른 데이터의 정보를 얻어올수 있다

컬럼 타입을 확인하는 방법도 있다

```objc
public func sqlite3_column_blob(_: OpaquePointer!, _ iCol: Int32) -> UnsafeRawPointer!
public func sqlite3_column_double(_: OpaquePointer!, _ iCol: Int32) -> Double
public func sqlite3_column_int(_: OpaquePointer!, _ iCol: Int32) -> Int32
public func sqlite3_column_int64(_: OpaquePointer!, _ iCol: Int32) -> sqlite3_int64
public func sqlite3_column_text(_: OpaquePointer!, _ iCol: Int32) -> UnsafePointer<UInt8>!
public func sqlite3_column_text16(_: OpaquePointer!, _ iCol: Int32) -> UnsafeRawPointer!
public func sqlite3_column_value(_: OpaquePointer!, _ iCol: Int32) -> OpaquePointer!
public func sqlite3_column_bytes(_: OpaquePointer!, _ iCol: Int32) -> Int32
public func sqlite3_column_bytes16(_: OpaquePointer!, _ iCol: Int32) -> Int32
public func sqlite3_column_type(_: OpaquePointer!, _ iCol: Int32) -> Int32
```

### SQLite State Controll

```objc
public func sqlite3_finalize(_ pStmt: OpaquePointer!) -> Int32
public func sqlite3_reset(_ pStmt: OpaquePointer!) -> Int32
```

둘다 상태 관리를 하기위해 사용된다

사용하지 않아서 자세한 사항은 모르겟다

### SQLite Function

```objc
public func sqlite3_create_function(_ db: OpaquePointer!, _ zFunctionName: UnsafePointer<CChar>!, _ nArg: Int32, _ eTextRep: Int32, _ pApp: UnsafeMutableRawPointer!, _ xFunc: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xStep: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xFinal: (@convention(c) (OpaquePointer?) -> Void)!) -> Int32
public func sqlite3_create_function16(_ db: OpaquePointer!, _ zFunctionName: UnsafeRawPointer!, _ nArg: Int32, _ eTextRep: Int32, _ pApp: UnsafeMutableRawPointer!, _ xFunc: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xStep: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xFinal: (@convention(c) (OpaquePointer?) -> Void)!) -> Int32

@available(macOS 10.7, *)
public func sqlite3_create_function_v2(_ db: OpaquePointer!, _ zFunctionName: UnsafePointer<CChar>!, _ nArg: Int32, _ eTextRep: Int32, _ pApp: UnsafeMutableRawPointer!, _ xFunc: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xStep: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xFinal: (@convention(c) (OpaquePointer?) -> Void)!, _ xDestroy: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32

@available(macOS 10.15, *)
public func sqlite3_create_window_function(_ db: OpaquePointer!, _ zFunctionName: UnsafePointer<CChar>!, _ nArg: Int32, _ eTextRep: Int32, _ pApp: UnsafeMutableRawPointer!, _ xStep: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xFinal: (@convention(c) (OpaquePointer?) -> Void)!, _ xValue: (@convention(c) (OpaquePointer?) -> Void)!, _ xInverse: (@convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void)!, _ xDestroy: (@convention(c) (UnsafeMutableRawPointer?) -> Void)!) -> Int32
```

> [!NOTE]
> 최신 버전은 ```sqlite3_create_function_v2``` 권장 하고 있습니다

파라미터 값 설명

db: 대상 데이터베이스 연결 객체
zFuncName: 생성 또는 재정의할 함수 이름 (UTF-8 인코딩, 최대 255 바이트)
nArg: 함수가 받는 인자 개수
-1: 가변 인자 (최대 SQLITE_LIMIT_FUNCTION_ARG 개)
양의 정수: 고정 인자 개수
eTextRep: 함수가 선호하는 문자열 인코딩 형식
SQLITE_UTF8 (기본값)
SQLITE_UTF16LE
SQLITE_UTF16BE
SQLITE_UTF16
pFunc: 함수 구현을 위한 callback 함수 포인터 (특정 함수에 따라 다름)
pArg: 함수 구현에 사용할 임의의 application data 포인터 (선택사항)
xDestroy: pArg 해제를 위한 callback 함수 포인터 (선택사항)

리턴값 설정 방법

SQLITE_OK: 성공
SQLITE_ERROR: 일반적인 오류
SQLITE_MISUSE: 함수 사용 오류 (예: 이름 길이 초과)

### SQLite 정보 가져오기

```objc
@available(macOS 13.0, *)
public func sqlite3_db_name(_ db: OpaquePointer!, _ N: Int32) -> UnsafePointer<CChar>!
```

이렇게 가져올 수 있는듯 하다?

```objc
@available(macOS 10.8, *)
public func sqlite3_db_filename(_ db: OpaquePointer!, _ zDbName: UnsafePointer<CChar>!) -> sqlite3_filename!
```

데이터 에 연결된 스키마를 가져온다고 한다

### SQLite Status

```objc
public func sqlite3_status(_ op: Int32, _ pCurrent: UnsafeMutablePointer<Int32>!, _ pHighwater: UnsafeMutablePointer<Int32>!, _ resetFlag: Int32) -> Int32
@available(macOS 10.11, *)
public func sqlite3_status64(_ op: Int32, _ pCurrent: UnsafeMutablePointer<sqlite3_int64>!, _ pHighwater: UnsafeMutablePointer<sqlite3_int64>!, _ resetFlag: Int32) -> Int32
```

sqlite 상태를 알려주는 것 같다

```objc
public func sqlite3_db_status(_: OpaquePointer!, _ op: Int32, _ pCur: UnsafeMutablePointer<Int32>!, _ pHiwtr: UnsafeMutablePointer<Int32>!, _ resetFlg: Int32) -> Int32
```

DB의 상태도 알 수 있다
