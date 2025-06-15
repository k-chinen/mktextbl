#
# mktextbl.awk - Make TeX table script
#        Convert tbl-format table to tabular-env. on LaTeX.
#
#   by k-chinen@is.aist-nara.ac.jp, 1992-1996, 2003-2004, 2025
#
# $Id: mktextbl.awk,v 1.2 1996/12/08 08:45:33 k-chinen Exp k-chinen $
#
# Note:
#   In 1992, This program was producuted for integration tbl to TeX.
#   Because TeX's tabular env. was complex than tbl.
#
#   And this program is useful to batch processing with script.
#
# Feature:
#   - Convert tbl-format table to LaTeX's tabular env.
#   - Warp other LaTeX commands for independed documents.
#
# Example:
#   1. Make follow scirpt, and name it to 'gfs'.
#
#       echo ".TS"
#       echo "box;"
#       echo "cc"
#       echo "lr."
#       awk 'BEGIN{print"name\tsize";exit}'
#       echo "_"
#       ls -lg | awk 'BEGIN{getline}{print $9"\t"$5}'
#       echo ".TE"
#   
#   2. Run 'gfs' and apply this program.
#
#       % sh ./gfs | gawk -f mktextbl.awk independ=on > fs.tex
#   
#   3. Make dvi-file
#       % latex fs
#

func formconv(s) {
    t = ""
    # gsub(/\ /,"",s);
    j = 1;
    if(flag["allbox"]!="")
        t = t "|";
    if(flag["box"]!="")
        t = t "|";
    if(flag["doublebox"]!="")
        t = t "||";
    
    k = 0;
    for(i = 1; i <= length(s); i++ ) {
        # acceptable format

        # get separation space
        _left = substr(s,i)
        if( match(_left, /^[\.0-9]+/) ) {
            # conver roff's en -> TeX's em 0.5 times
            ennum = substr(_left, RSTART, RLENGTH)
            if(ennum == "0") {
                t = t "@{}"
            }
            else {
                emnum = sprintf("%.2fem", ennum*.5)
                t = t "@{\\hspace{" emnum "}}"
            }
            i+= RLENGTH - 1
        }

        fchar = tolower(substr(s,i,1));
        if( match(fchar,/[lrcsbi_=|]/) ) {
            t = t fchar;
            if(substr(s,i+1,1)!="s" && flag["allbox"]!="") {
            }
            if(match(substr(s,i+1,1), /[lrc_=]/) && flag["allbox"]!="") {
                t = t "|";
            }
            j++;
        }
        if( match(fchar,/[lrcs_=]/) ) {
            k++;
        }
        if(k>maxcolumn) {
            maxcolumn = k;
        }
    }
    
    if(flag["allbox"]!="")
        t = t "|";
    if(flag["box"]!="")
        t = t "|";
    if(flag["doublebox"]!="")
        t = t "||";
    
    gsub(/\|\|+/,"||",t);
    return t
}

func fullconv(s) {
    fc = split(s,v)
    for(i=1;i<=fc;i++) {
        if(v[i] ~ /^\\_/) {
        }
        else {
            printf "%s ", v[i];
        }
        if(i!=fc) {
            printf " & ";
        }
    }
    print " \\\\"
    for(i=1;i<=fc;i++) {
        if(v[i] ~ /^\\_/) {
            printf "\\cline{%d-%d}\n",i,i;
        }
    }
}

BEGIN{
    STDERR = "/dev/stderr"
    FS ="[\t]"
    intbl = 0;
    hasform = 0;
    hasstyle = 0;
    maxcolumn = -1;
    sline = -1;     # start line
    tline = -1;     # table line
    for(i=1;i<ARGC;i++) {
        # printf "%2d:%d:%s\n",i,match(ARGV[i],"="),ARGV[i];
        if(match(ARGV[i],"=")) {
            split(ARGV[i],v,"=");
            if(v[2]=="off") {
            }
            else
            if(v[2]=="no") {
            }
            else {
                flag[v[1]]=v[2];
                gflag[v[1]]=v[2];
                # printf "%% flag:%s = %s\n",v[1],flag[v[1]];
            }
        }
    }
    if(gflag["independ"]!="") {
        print "\\documentstyle[a4j]{jarticle}"
        print "\\begin{document}"
    }
    if(flag["centering"]!="") {
        print "\\begin{center}"
    }
}
END{
    if(intbl) {
        print "Warning: No '.TE'" > STDERR
    }
    if(flag["centering"]!="") {
        print "\\end{center}"
    }
    if(gflag["independ"]!="") {
        print "\\end{document}"
    }
}
/^\.TS/{
    intbl = 1;
    sline = NR;
    FS ="[\t]"
    print ""
    print "%"
    printf "%% Table from %s ,by mktextbl.awk\n",FILENAME;
    print "%"
    for(i in gflag) {
        flag[i] = gflag[i]
    }
    next;
}
/\;$/{
    if(intbl && !hasstyle) {
        $0 = substr($0,1,length($0)-1);
        split($0,style,",");
        for(i in style) {
            j = index(style[i],"(")
            if(j>0) {
                k = index(style[i],")")
                flag[substr(style[i],1,j-1)] = substr(style[i],j+1,k-j-1)
            }
            else {
                flag[style[i]]="on"
            }
        }
        if(flag["nocenter"]) {
            flag["center"] = "";
        }
        sline = NR
        next;
    }
}
/\.$/{
    if(intbl && !hasform ){
        gsub(/\ /,"",$0);
#        form = formconv($0)
        _raw = substr($0, 1, length($0)-1)
        form = formconv(_raw)
        defaultform = form
        
        if(flag["center"]!="") {
            print "\\begin{center}"
        }
        
        gsub("b", "", form);
        gsub("i", "", form);
        
        printf "\\begin{tabular}{%s}\n",form
        
        sline = NR
        tline = NR
        
        if(flag["allbox"]!="") {
            print "\\hline"
        }
        if(flag["box"]!="") {
            print "\\hline"
        }
        if(flag["doublebox"]!="") {
            print "\\hline \\hline"
        }
        
        if(flag["tab"]!="") {
            FS = flag["tab"]
        }

        next;
    }
}
/^\.TE/{
    if(intbl) {
        if(flag["box"]!="") {
            print "\\hline"
        }
        if(flag["doublebox"]!="") {
            print "\\hline \\hline"
        }
        
        print "\\end{tabular}";
        intbl = 0;
        
        if(flag["center"]!="") {
            print "\\end{center}"
        }
        
        print ""
    }
    tline = -1;
    hasform = 0;
    hasstyle = 0;
    maxcolumn = -1;

    for(i in pform) {
        delete pform[i]
    }
    for(i in flag) {
        delete flag[i]
    }
    defaultform = ""

    next;
}
(intbl&&(tline==-1)){
    pform[NR-sline] = formconv($0)
    next;
}

# /^%/{
#     print $0
#     next
# }
/^_/{
    if(intbl) {
        print "\\hline"
        tline++

        hasstyle = 1;
        hasform = 1;

        next;
    }
}
/^=/{
    if(intbl) {
        print "\\hline \\hline"
        tline++

        hasstyle = 1;
        hasform = 1;

        next;
    }
}
(intbl){
    # escape symbols
    gsub(/%/,"\\%");
    gsub(/_/,"\\_");
    gsub(/{/,"\\{");
    gsub(/}/,"\\}");

    if(1) {
        if(pform[NR-tline]!="") {
            thisform = pform[NR-tline]
        }
        else {
            thisform = defaultform
        }

        auxline = ""

        # skip empty row or horizontal line row
        act = 0;
        for(i=1;i<=length(thisform);i++) {
            if($i ~ /^$/) {
            }
            else
            if($i ~ /^\\_/) {
            }
            else {
                act = 1;
            }
        }

        if(act) {
            k = 1;
            i = 1;
            while(k<=maxcolumn && i<=length(thisform)) {
                w = 1               
                form = ""
                cont = $k

                while(substr(thisform,i,1)=="|") {
                    form = form "|"
                    i ++;
                }

                mcmd = substr(thisform,i,1)
                if(mcmd == "_" || mcmd == "=") {
                    form = form "l" # dummy
                }
                else {
                    form = form mcmd 
                }


                j = i+1;

                face = ""
                if(substr(thisform,j,1)=="b") {
#                   face = "\\sf "
                    face = "\\bf "
                    j++;
                }
                else
                if(substr(thisform,j,1)=="i") {
                    face = "\\it "
                    j++;
                }
                else {
                }
                
                while(substr(thisform,j,1)=="s") {
                    w++;
                    j++;
                }
                while(substr(thisform,j,1)=="|") {
                    form = form "|"
                    j ++;
                }
                
                if(pform[NR-tline]!="") {
                    if(mcmd == "_" || mcmd == "=") {
#                       cont = "";
                        auxline = auxline "\\cline{" k "-" k "}";
                    }
                    printf "\\multicolumn{%d}{%s}{%s%s} ",w,form,face,cont
                }
                else {
                    if(cont ~ /^\\_/) {
                        printf "\\null "
                    }
                    else {
                        printf "%s%s ", face, cont
                    }
                }
                i = j
#                if(i<length(thisform))
#                    printf "& "
                if(w>1) {
                    k += w-1;
                }
                if(k<maxcolumn) {
                    printf "& "
                }

                k ++;

            }
            printf "\\\\ \n"

        }
        else {
            for(i=1;i<=NF;i++) {
                if($i ~ /^\\_/) {
                    printf "\\cline{%d-%d} ",i,i;
                }
            }
            print ""
        }

        if(pform[NR-tline]!="") {
            hasstyle = 1;
            hasform = 1;
        }
    }

    if(auxline != "") {
        print auxline;
    }
    
    if(flag["allbox"])
        print "\\hline"
    
    next;
}
{
    print $0
}
