#!/bin/bash
#
# @Author: Michał Ratajewski
#

DB=""

function help() {
    echo "Zbiór obsługiwanych poleceń"
    echo ""
    echo " [ exit ] - wyjście z skryptu"
    echo " [ help ] - Zbiór obsługiwanych poleceń"
    echo " [ create {sciezka z nazwa pliku} ] - Utworzenie bazy danych"
    echo " [ remove {sciezka z nazwa pliku} ] - Usunięcie bazy danych"
    echo " [ open {sciezka z nazwa pliku} ] - Otwarcie bazy danych, wymagane by rozpocząć operacje na bazie danych!"
    echo " [ addRow ] - Dodawanie nowego rekordu do bazy danych"
    echo " [ rmRow {linia rekordu} ] - Usunięcie rekordu z bazy danych na podstawie lini w której się znajduje"
    echo " [ addCol {nazwa kolumny}  ] - Dodawanie nowej kolumny do bazy danych"
    echo " [ rmCol {nazwa kolumny}  ] - Usunięcie istniejącej kolumny do bazy danych"
    echo " [ display  ] - Wyświetlenie danych z bazy danych wyjście z podglądu przyciskiem 'Q'"
    echo ""
}

function HelloBanner() {
    echo "Skrypt do tworzenia i zarzadzania baz danych na podstawie plików CSV"
    echo "Uzyj polecnia 'help' by dowiedzieć się wiecej an temat mozliwości!"
    echo ""
}

# Dodawnie nowej kolumny
function addColumn() {
    header=$(head -n 1 "$DB")
    if [[ ! -z $header ]]; then
        if [[ $header =~ $1 ]]; then
            echo "Podana kolumna juz istnieje!";
        else
            header="$header,$1"
            touch "$DB.temp"
            echo $header > "$DB.temp"
            tail -n +2 "$DB" | while IFS=, read -r line; do
                echo "$line,''" >> "$DB.temp"
            done
            rm $DB
            mv "$DB.temp" $DB
            echo "Dodano nową kolume '$1' !";
        fi
    else
        header="$1"
        touch "$DB.temp"
        echo $header > "$DB.temp"
        tail -n +2 "$DB" | while IFS=, read -r line; do
            echo "$line,''" >> "$DB.temp"
        done
        rm $DB
        mv "$DB.temp" $DB
        echo "Dodano nową kolume '$1' !";
    fi
}

# Usuwanie istniejacej kolumny
function rmColumn() {
    header=$(head -n 1 "$DB")
    if [[ ! -z $header ]]; then
        if [[ ! $header =~ $1 ]]; then
            echo "Podana kolumna nie istnieje!";
        else
            index_to_remove=$(echo "$header" | awk -v col="$1" -F',' '{for (i=1;i<=NF;i++) if ($i==col) print i}')
            touch "$DB.temp"
            header=$(echo "$header" | awk -v idx="$index_to_remove" -v FS="," -v OFS="," '{$idx=""; sub(/,+/,",")} 1')
            echo $header > "$DB.temp"
            tail -n +2 "$DB" | awk -v idx="$index_to_remove" -v FS="," -v OFS="," '{$idx=""; sub(/,+/,",")} 1' >> "$DB.temp"
            rm $DB
            mv "$DB.temp" $DB
            echo "Usunięto kolume '$1' !";
        fi
    else
        echo "Baza nie posiada kolumn do usnięcia!";
    fi
}

# Dodwanie nowego wiersza
function addRow() {
    header=$(head -n 1 "$DB")
    if [[ ! -z $header ]]; then
        columns=$(echo "$header" | awk -F',' '{for (i=1; i<=NF; i++) print $i}')
        ROW=""
        echo "Podaj wartości danych kolumn:"
        echo ""
        for column in $columns; do
            read -p "$column = " value
            if [[ -z $ROW ]]; then
                ROW="$value"
            else
                ROW="$ROW, $value"
            fi
        done
        echo $ROW >> $DB
        echo ""
        echo "Pomyślnie dadano nowy rekord!"
    else
        echo "Baza danych nie posiada zadnych kolumn!"
    fi
}

# Pętla obsługi komend
function cmd() {
    echo ""
    case $1 in
        "exit")
            echo "Wychodzenie z programu..."
            exit 0 ;;
        "open")
            if [[ ! -z $2 && -f $2 ]]; then
                DB=$2
                echo "Otwarto baza danych!"
            elif [ -z $2 ]; then
                echo "Do otwarcia bazy danych potrzebna jest ściezka do pliku!"
            else
                echo "Podany plik nie istnieje!"
            fi;;
        "create")
            if [[ ! -z $2 && ! -f $2 ]]; then
                DB=$2
                touch $2
                echo "Stworzono baza danych!"
            elif [ -z $2 ]; then
                echo "Do stworzenia bazy danych potrzebna jest ściezka do pliku!"
            else
                echo "Podany plik juz istnieje!"
            fi;;
        "remove")
            if [[ ! -z $2 && -f $2 ]]; then
                rm $2
                echo "Usunięto bazę danych!"
            elif [[ -z $2 ]]; then
                echo "Do usunięcia bazy danych potrzebna jest ściezka do pliku!"
            else
                echo "Podany plik nie istnieje!"
            fi;;
        "addRow")
            addRow;;
        "display")
            if [[ -f $DB ]]; then
                less $DB
            fi;;
        "addCol")
            if [[ ! -z $2 && -f $DB ]]; then
                addColumn $2
            elif [[ -z $DB ]]; then
                echo "Do dodanie kolumny potrzebne jest najpierw otwarcie bazy danych!!"
            elif [[ -z $2 ]]; then
                echo "Do dodanie kolumny potrzebny nazwa kolumny!"
            fi;;
        "rmCol")
            if [[ ! -z $2 && -f $DB ]]; then
                rmColumn $2
            elif [[ -z $DB ]]; then
                echo "Do usuniecia kolumny potrzebne jest najpierw otwarcie bazy danych!!"
            elif [[ -z $2 ]]; then
                echo "Do usuniecia kolumny potrzebny nazwa kolumny!"
            fi;;
        "rmRow")
            if [[ ! -z $2 && -f $DB ]]; then
                sed -i "$2d" $DB
                echo "Usunięto rekord znajdujący się w $2 lini!"
            elif [[ -z $DB ]]; then
                echo "Do usuniecia kolumny potrzebne jest najpierw otwarcie bazy danych!!"
            elif [[ -z $2 ]]; then
                echo "Do usuniecia rekordu potrzebny jest numer lini w której się znajduje!"
            fi;;
        "help")
            help ;;
        *)
            echo "Podane polecenie nie istnieje!";;
    esac
    echo ""
}

HelloBanner
while true
do
    read -p "Polecenie >> " command
    cmd $command
done;
