#!/bin/bash
pega(){
   site='https://statusinvest.com.br/'
   wget "$site$2$1" 1> /dev/null 2>&1
   inteiro=`cat $1 | grep --max-count=1 strong | sed 's/[^0-9]//g'`
   final=`echo "scale=2 ; $inteiro/100" | bc`
   rm "$1"
   export final
}
cadastrar(){
   read -p "código empresa: " codigo
   read -p "valor pago: " valor
   read -p "quantidade: " quanti
   read -p "tipo:" tipo
   echo "$codigo $quanti $valor $tipo" >> dolar.txt
}
espaco(){
   echo " "
}
ver(){
   espaco
   echo '| EMPRESA | COMPRA | T.COMPRA | QUANT. | POSICAO | VALOR ATUAL |'
   linhas=`cat dolar.txt | grep -c ''`
   for ((c=1;c<=$linhas;c++))
   do
       empresa=`cat dolar.txt | sed -n $c'p' | awk '{print $1}'`
       quanti=`cat dolar.txt | sed -n $c'p' | awk '{print $2}'`
       valor=`cat dolar.txt | sed -n $c'p' | awk '{print $3}'`
       tipo=`cat dolar.txt | sed -n $c'p' | awk '{print $4}'`
       pega "$empresa" "$tipo"
       posicao=`echo "scale=2 ; $final*$quanti" | bc`
       posini=`echo "scale=2 ; $valor*$quanti" | bc`
       espaco
       echo "$empresa       $valor      $posini      $quanti      $posicao     $final"
    done
    posicao
}
excluir(){
   read -p "digite o nome da empresa: " empre
   cat dolar.txt | grep -v "$empre" > temp.txt
   cat temp.txt > dolar.txt
}
ranking(){
   linhas=`cat empresas.txt | grep -c ''`
   for ((c=1;c<=$linhas;c++))
   do
     empresa=`cat empresas.txt | sed -n $c'p'`
     wget "https://statusinvest.com.br/acoes/$empresa" 1> /dev/null 2>&1
     cat $empresa | grep 'class="value d-block lh-4 fs-4 fw-700"' | cut -c47-55 | sed 's/[^0-9-]//g' > rtemp.txt
     roe=`cat rtemp.txt | sed -n '25p'`
     roic=`cat rtemp.txt | sed -n '27p'`
     pvpa=`cat rtemp.txt | sed -n '4p'`
     marbru=`cat rtemp.txt | sed -n '21p'`
     mebitda=`cat rtemp.txt | sed -n '22p'`
     cagr=`cat rtemp.txt | sed -n '29p'`
     mebit=`cat rtemp.txt | sed -n '23p'`
     liqcor=`cat rtemp.txt | sed -n '20p'`

     roe=` echo "scale=2 ; 5*($roe/100)" | bc`
     roic=` echo "scale=2 ; 5*($roic/100)" | bc`
     pvpa=` echo "scale=2 ; 5/$pvpa" | bc`
     marbru=` echo "scale=2 ; 5*($marbru/200)" | bc`
     mebitda=` echo "scale=2 ; 5*($mebitda/200)" | bc`
     cagr=` echo "scale=2 ; 5*($cagr/100)" | bc`
     liqcor=` echo "scale=2 ; 5*($liqcor/100)" | bc`

     resultado=`echo "scale=3 ; $roe+$roic+$pvpa+$marbru+$mebitda+$cagr+$liqcor" | bc `
     echo "$resultado $empresa $roe $roic $pvpa $marbru $mebitda $cagr $liqcor" >> ranking.txt
     rm "$empresa"
     clear
     echo "LOADING"
     printf '{'
     for ((k=1;k<$c;k++))
     do
         printf '#'
     done
     for ((j=1;j<($[ $linhas-$c ]);j++))
     do
         printf '-'
     done
     printf '}'
  done
  clear
  cat ranking.txt | sort -n
  rm ranking.txt
}
posicao(){
   tipos=( "acoes/" "fundos-imobiliarios/" "etfs\|bdrs" )
   facoes=( 0 0 0 )
   for ((p=0;p<3;p++))
   do
      linha=`cat dolar.txt | grep -c "${tipos[$p]}"`
      for ((c=1;c<$linha;c++))
      do
          empresa=`cat dolar.txt | grep "${tipos[$p]}" | sed -n $c'p' | awk '{print $1}'`
          quanti=`cat dolar.txt | grep "${tipos[$p]}" | sed -n $c'p' | awk '{print $2}'`
          tipo=`cat dolar.txt | grep "${tipos[$p]}" | sed -n $c'p' | awk '{print $4}'`

          pega "$empresa" "$tipo"
          facoes[$p]=`echo "scale=2 ; ${facoes[$p]}+$final*$quanti" | bc`
       done
   done
   total=`echo "scale=2 ; ${facoes[0]}+${facoes[2]}+${facoes[1]}" | bc`
   tf=`echo "scale=2 ; (${facoes[1]}/$total)*100" | bc`
   ac=`echo "scale=2 ; (${facoes[0]}/$total)*100" | bc`
   et=`echo "scale=2 ; (${facoes[2]}/$total)*100" | bc`
   espaco
   echo $ac"% em acoes brasil"
   echo $tf"% em fundos imobiliarios"
   echo $et"% em açoes exterior"
}
while [ 0 ]
do
   espaco
   echo "[v] ver todas"
   echo "[c] cadastrar"
   echo "[E] excluir"
   echo "[R] ranking"
   read -p "[s] sair "  opcao
   case $opcao in
      's'|'S') break ;;

      'V'|'v')ver ;;

      'c'|'C') cadastrar ;;

       'e'|'E') excluir ;;

       'r' |'R') ranking ;;
      *) echo 'opção invalida' ;;
    esac
done
