#!/bin/sh

#####
## OPTIONS

DEFAULT_DICTIONARY="en_fr"
DEFAULT_COMMAND="exactmatch"

DICTIONARY_DIRECTORY="${HOME}/.local/share/shdic"

NEW_LINE=»
GREP_FLAGS="--ignore-case --mmap"


#####

print_help_exit()
{
    echo "Match a word exactly: ";
    echo "      shdic.sh <dictionary> exactmatch <word>";
    echo "Match words using a pattern: ";
    echo "      shdic.sh <dictionary> wordsearch <pattern>";
    echo "Search for a given pattern in each article: ";
    echo "      shdic.sh <dictionary> fullsearch <pattern>";
    echo "If command or both command and dictionary are omitted -- the default ones are used."
    echo "";
    echo "";
    echo "Convert dictionary: ";
    echo "      shdic.sh convert_mueller input.dict.dz output.shdic";
    echo "      shdic.sh convert_tei input.tei output.shdic";
    exit 0;
}


COMMAND="${DEFAULT_COMMAND}";
DICTIONARY="${DEFAULT_DICTIONARY}";

case $# in
    0)  print_help_exit;;

    1)  PATTERN="$1";;

    2)  case ${1} in
            exactmatch)
                COMMAND="$1";
                PATTERN="$2";
                ;;
            wordsearch)
                COMMAND="$1";
                PATTERN="$2";
                ;;
            fullsearch)
                COMMAND="$1";
                PATTERN="$2";
                ;;
            *)
                DICTIONARY="$1";
                PATTERN="$2";
                ;;
        esac
        ;;

    3)  case ${1} in
            convert_mueller)
                COMMAND="$1";
                INPUT_FILE="$2";
                OUTPUT_FILE="$3";
                ;;
            convert_tei)
                COMMAND="$1";
                INPUT_FILE="$2";
                OUTPUT_FILE="$3";
                ;;
            convert_transcription)
                COMMAND="$1";
                INPUT_FILE="$2";
                OUTPUT_FILE="$3";
                ;;
            *)
                DICTIONARY="$1";
                COMMAND="$2";
                PATTERN="$3";
                ;;
        esac
        ;;

    *)  print_help_exit;;
esac

DICTIONARY="${DICTIONARY_DIRECTORY}/${DICTIONARY}"


case ${COMMAND} in
    exactmatch)
        LESS_PATTERN="${PATTERN}";
        SEARCH_CMD="look -f ${PATTERN}${NEW_LINE} ${DICTIONARY}";;

    wordsearch)
        LESS_PATTERN="${PATTERN}";
        #GREP_FLAGS="${GREP_FLAGS} --max-count=1"
        PATTERN="^${PATTERN}${NEW_LINE}";
        SEARCH_CMD="grep ${GREP_FLAGS} ${PATTERN} ${DICTIONARY}";;

    fullsearch)
        LESS_PATTERN="${PATTERN}";
        SEARCH_CMD="grep ${GREP_FLAGS} ${PATTERN} ${DICTIONARY}";;

    convert_mueller)
        TMP_FILE=/tmp/shdic.dict

        rm -Rf ${TMP_FILE}
        rm -Rf ${TMP_FILE}.tmp

        cp ${INPUT_FILE} ${TMP_FILE}.tmp
        gzip -S ".tmp" -d ${TMP_FILE}.tmp

        awk '{
            NEW_LINE="»"

            if (match($0, "^[^ ]"))
            {
                if (line != "")
                {
                    if (result == "")
                    {
                        result = line
                    }
                    else
                    {
                        print result
                        result = line
                    }
                }
                line = $0
                sub(/ \//, NEW_LINE" /", line)
            }
            else
            {
                line = line NEW_LINE $0
            }
        }' ${TMP_FILE} | sort --ignore-case > ${OUTPUT_FILE}

        rm -Rf ${TMP_FILE}
        exit 0
        ;;

    convert_tei)
        TMP_FILE=/tmp/shdic.dict

        rm -Rf ${TMP_FILE}

        cat ${INPUT_FILE} \
            | sed -n '/<text>/,/<\/text>/p' \
            | sed -e '/^ *<[^<]*>$/d' -e 's/^ *<orth>//' -e 's/<\/orth>//' -e 's/^    //' -e 's/<\/*quote>//g' -e 's/<\/*pron>//g' > ${TMP_FILE}

        awk '{
            NEW_LINE="»"

            if (match($0, "^[^ ]"))
            {
                if (line != "")
                {
                    if (result == "")
                    {
                        result = line
                    }
                    else
                    {
                        print result
                        result = line
                    }
                }
                line = $0
                sub(/ \//, NEW_LINE" /", line)
            }
            else
            {
                line = line NEW_LINE $0
            }
        }' ${TMP_FILE} | sort --ignore-case > ${OUTPUT_FILE}

        rm -Rf ${TMP_FILE}
        exit 0;
        ;;

    convert_transcription)
        # dз -> ʤ
        # tS -> ʧ
        # З -> ð
        # E -> ɛ
        # I -> ɪ
        # N -> ŋ
        # Э -> æ
        # S -> ʃ
        # Ф -> θ
        # з -> ʒ
        # O -> ɔ
        # э -> ə
        # A -> ʌ
        # ' -> ˈ
        # , -> ˌ
        sed -e "s/\[\([^]]*\)dз\([^]]*\)\]/[\1ʤ\2]/g" \
            -e "s/\[\([^]]*\)tS\([^]]*\)\]/[\1ʧ\2]/g" \
            -e "s/\[\([^]]*\)З\([^]]*\)\]/[\1ð\2]/g" \
            -e "s/\[\([^]]*\)E\([^]]*\)\]/[\1ɛ\2]/g" \
            -e "s/\[\([^]]*\)I\([^]]*\)\]/[\1ɪ\2]/g" \
            -e "s/\[\([^]]*\)N\([^]]*\)\]/[\1ŋ\2]/g" \
            -e "s/\[\([^]]*\)Э\([^]]*\)\]/[\1æ\2]/g" \
            -e "s/\[\([^]]*\)S\([^]]*\)\]/[\1ʃ\2]/g" \
            -e "s/\[\([^]]*\)Ф\([^]]*\)\]/[\1θ\2]/g" \
            -e "s/\[\([^]]*\)з\([^]]*\)\]/[\1ʒ\2]/g" \
            -e "s/\[\([^]]*\)O\([^]]*\)\]/[\1ɔ\2]/g" \
            -e "s/\[\([^]]*\)э\([^]]*\)\]/[\1ə\2]/g" \
            -e "s/\[\([^]]*\)A\([^]]*\)\]/[\1ʌ\2]/g" \
            -e "s/\[\([^]]*\)'\([^]]*\)\]/[\1ˈ\2]/g" \
            -e "s/\[\([^]]*\),\([^]]*\)\]/[\1ˌ\2]/g" \
            ${INPUT_FILE} > ${OUTPUT_FILE};
        exit 0;
        ;;

    *)  print_help_exit;;
esac


${SEARCH_CMD} | awk "gsub(\"${NEW_LINE}\",\"\n\")" | less -I -p "${LESS_PATTERN}"
