#!/bin/bash
#-------------------------------------------------------
#Nome : Ana Paula Fernandes de Souza
#Matricula: 0022647
#Atualização : 27/03/2018
#Assunto : Converter arquivos .docx em html com uma pasta
# de imagens.
#Precisa do pacote : parallel
#-------------------------------------------------------

criaArquivoHtml(){

URL="./images/"

COUNT=1;
while read line 
do 
    if echo "$line" | egrep '<img src=' >/dev/null
    then
        URL_NOVA="<img src='"$URL"image"$COUNT".jpg'>"
        #echo $line | sed 's/<img src=.*/$URL_NOVA/'
        
        echo $URL_NOVA;
        COUNT=$(expr $COUNT + 1)

    #não faz nada
    else
	    echo $line
    fi
    #URL_NOVA=\"<img src=\'$URLteste.jpg\">

done < original.html

}

eliminaLinhasEmBranco(){

    #retirar os </br> do arquivo.
    sed -i 's/<br\/>/ /g' original.html

    #retirar linhas em branco.
    awk 'NF>0' original.html > novoarquivo.html
    rm original.html
    mv novoarquivo.html original.html
}

organizandoPastas(){

    #trazendo a pasta para a $var raiz.
    cd ..
    mv media ..
    cd ..
    mv media/ images/
    
    #movendo arquivos para pasta raiz do script
    mv images ..
    mv original.html ..
    cd ..
        
    #removendo pasta original e criando outra com apenas arquivos necessários.
    rm -R $var
    mkdir $var
    mv original.html $var
    mv images/ $var
}

apagaImagensPNG(){

    #apaga todas as imagens .png
    for j in *.png ; 
    do 
       rm $j
    done
}

#prefixo das imagens.
#num=1

#sufixo das imagens.
num2=0

#intalar depedencias.
#sudo apt install parallel 

#Retirar os espaco do arquivo.
#ls -w1 *.docx | while read line; do mv "$line" "$(echo $line | tr '\ ' '-')"; done

#retirar o . do inicio.
#for i in *.docx ; 
#do 
#    var=`ls *.* | grep -e $i | cut -d "." -f2`
#    mv $i $var'.docx'
#done

#trabalhando em todos os documentos(docx).
for i in *.docx ; 
do 
    echo "==================Trabalahndo no arquivo $i =================="

    #pegar o nome do arquivo sem extensão.
    var=`ls *.* | grep -e $i | cut -d "." -f1`
    
    #criar pasta com o nome do arquivo.
    mkdir $var
    
    #converter .docx para html e modificar o nome
    soffice --headless --convert-to html  $i > /dev/null
    mv $var'.html' 'original.html'
    
    #mover para a pasta    
    mv 'original.html' $var
    
    #colocar a extesao.zip,extrair e remover
    mv $i $i'.zip'
    unzip $i'.zip' -d $var > /dev/null
    rm $i'.zip'

    cd $var/word    
    cd media/
    num2=$(expr $num2 + 1)

    #converter todas as imagens .png em jpg.
    ls  *.png | parallel convert '{}' '{.}.jpg' > /dev/null

    #chamando funcao
    apagaImagensPNG
        
    #renomear o nome das imagens acrescentando um prefixo no inicio.
    #for j in *.jpg ; 
    #do 
    #    mv $j $num'.'$num2$j
    #    echo $num'.'$num2 > prefixo.txt        
    #done

    #chamando funcao
    organizandoPastas
    
    cd $var
    #chamando funcao
    eliminaLinhasEmBranco
    cd .. 

    cd $var    
    
    #chamando funcao
    criaArquivoHtml >index.html    

    rm original.html
    cd ..

    echo "================== Criado pastas e arquivo html para :  $i =================="    
done

