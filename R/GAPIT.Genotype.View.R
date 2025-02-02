`GAPIT.Genotype.View` <-function(GI=NULL,X=NULL,chr=NULL, cut.dis=1,n.select=10000,
                                 WS0=100000,Aver.Dis=1000,...){
# Object: Analysis for Genotype data:Distribution of SNP density,Accumulation,Moving Average of density,result:a pdf of the scree plot
# myG:Genotype data
# chr: chromosome value
# WS0 is the cutoff threshold for marker to display
# ws is used to calculate within windowsize
# Aver.Dis is average display windowsize
# mav1:Moving Average set value length
# Authors:  Zhiwu Zhang and Jiabo Wang
# Last update: AUG 24, 2022 
##############################################################################################

#if(nrow(myGI)<1000) return() #Markers are not enough for this analysis
  
if(is.null(GI)){stop("Validation Invalid. Please select read valid Map flies  !")}
if(is.null(X)){stop("Validation Invalid. Please select read valid Genotype flies  !")}

## sorted number of chromosome by numeric and charicter
# GI=myGM
#
chor_taxa=as.character(unique(GI[,2]))
chor_taxa=chor_taxa[order(as.numeric(as.character(chor_taxa)))]
letter.index=grep("[A-Z]|[a-z]",chor_taxa)

if(!setequal(integer(0),letter.index))
  {     
  # myGI=as.matrix(myGI)
      if(length(letter.index)!=length(chor_taxa))
        {
          chr.letter=chor_taxa[letter.index]
          chr.taxa=chor_taxa[-letter.index]
        }else{
          chr.letter=chor_taxa
          chr.taxa=NULL
        }
      Chr=as.character(GI[,2])
      for(i in letter.index)
        {
         index=Chr==chor_taxa[i]
         Chr[index]=i 
        }
      GI[,2]=as.data.frame(Chr)
  }

GI2=GI[order(as.numeric(as.matrix(GI[,3]))),]
GI2=GI2[order(as.numeric(as.matrix(GI2[,2]))),]
rs2=as.character(GI2[,1])
rs1=as.character(GI[,1])
index=match(rs2,rs1)
X=X[,index]
GI=GI2

chr=as.character(as.matrix(unique(GI[,2])))
allchr=as.character(GI[,2])

## make an index for marker selection with binsize
print("Filting marker for GAPIT.Genotype.View function ...")
pos.fix=as.numeric(GI[,2])*10^(nchar(max(as.numeric(GI[,3]))))+as.numeric(GI[,3])

## select markers from bins
# binsize=10000
# bins=ceiling(pos.fix/binsize)
# n.bins=length(unique(bins))
# uni.bins=unique(bins)

# n.markers=nrow(GI)

# if(n.markers<n.select)n.select=n.markers
# n.targ=floor(n.select/n.bins)
# if(n.targ<1)
# {
#   n.targ=1
#   uni.bins=sample(uni.bins,n.select)
# }
# rs.markers=NULL
# for(i in uni.bins)
# {
#   map0=GI[bins==i,]
#   n.targ0=n.targ
#   if(nrow(map0)<n.targ)n.targ0=nrow(map0)
#   rs.markers=append(rs.markers,as.character(map0[sample(1:(nrow(map0)),n.targ0),1]))
# }

# rs.markers=unique(rs.markers)
# rs.index=as.character(GI[,1])%in%rs.markers
# print(table(rs.index))

set.seed(99163)
if(is.null(n.select))n.select=nrow(GI)
rs.index=sample(nrow(GI),n.select)
rs.index=sort(rs.index)

## filter genotype by rs.index
GI2=GI[rs.index,]
X2=X[,rs.index]

dist=abs(as.numeric(GI2[-1,3])-as.numeric(GI2[-nrow(GI2),3]))
dist.out=GAPIT.Remove.outliers(dist,pro=0.1,size=1.1)
# WS0=10000
if(is.null(WS0)) WS0=((max(dist,na.rm=TRUE))%/%1000)*1000
if(WS0==0)WS0=1
index=dist>WS0
dist[index]=NA
# X=myGD
x1=X2[,-ncol(X2)]
x2=X2[,-1]

## set different colors for odd or even chromosome
m=ncol(X2)
theCol=as.numeric(GI2[,2])%%2 # here should work, based on the Chr is numeric values
colDisp=array("gray50",m-1)
colIndex=theCol==1
colDisp[colIndex]="goldenrod"
colDisp=colDisp

# GI2=GI[rs.index,]
chr.pos=rep(NA,length(chr))
chr.pos2=rep(1,length(chr)+1)
rownames(GI2)=1:nrow(GI2)
mm=nrow(GI2)
for(i in 1:length(chr))
{
  chr.pos[i]=floor(median(as.numeric(rownames(GI2[GI2[,2]==chr[i],]))))
  chr.pos2[i+1]=max(as.numeric(rownames(GI2[GI2[,2]==chr[i],])))
}
odd=seq(1,length(chr),2)
r=mapply(GAPIT.Cor.matrix,as.data.frame(x1),as.data.frame(x2))
# r2=mapply(GAPIT.Cor.matrix,as.data.frame(x3),as.data.frame(x4))
# r=append(r1,r2)
r[is.na(r)]=0
d.V=dist/Aver.Dis

grDevices::pdf("GAPIT.Genotype.Distance_R_Chro.pdf", width =10, height = 6)
# print(summary(d.V))
par(mfcol=c(1,2),mar = c(5,5,2,2))
plot(r, xlab="Marker",las=1,xlim=c(1,mm),ylim=c(-1,1),
    ylab="R",axes=FALSE, main="a",cex=.5,col=colDisp)
axis(1,at=chr.pos2,labels=rep("",length(chr)+1))
axis(1,at=chr.pos[odd],labels=chr[odd],tick=FALSE)
axis(2,las=1)

# aa=d.V[rs.index]

plot(d.V,las=1, xlab="Marker", ylab="Distance (Kb)",xlim=c(1,mm), ylim=c(0,ceiling(max(d.V,na.rm=TRUE))),
    axes=FALSE,main="b",cex=.5,col=colDisp)
axis(1,at=chr.pos2,labels=rep("",length(chr)+1))
axis(1,at=chr.pos[odd],labels=chr[odd],tick=FALSE)
axis(2,las=1)
grDevices::dev.off()

grDevices::pdf("GAPIT.Genotype.Distance_R_Rsqaure.pdf", width =10, height = 6)
par(mfcol=c(1,2),mar = c(5,5,2,2))
plot(d.V,r,las=1,xlab="Distance (Kb)",ylim=c(-1,1),pch=16,
  ylab="R",main="a",cex=.5,col="gray60",xlim=c(0,WS0/Aver.Dis))
abline(h=0,col="darkred")
plot(d.V,r^2,las=1,xlab="Distance (Kb)",ylim=c(0,1),pch=16,
  ylab="R sqaure", main="b",cex=.5,col="gray60",xlim=c(0,WS0/Aver.Dis))

#Moving average
# dist2[dist2>WS0]=NA
# max.dist=max(GI[,3])
dist[dist==0]=1
indOrder=order(dist)
ma=cbind(as.data.frame(dist),as.data.frame(r)^2)
ma=ma[indOrder,]
index.na=ma[,1]>WS0
maPure=ma[!index.na,]
maPure=maPure[!is.na(maPure[,1]),]
# ws=10000
# if(is.null(ws))ws=floor(max(dist,na.rm=T)/50)

ns=maPure[,1]
# slide=ws
# n.bin=ceiling(ns/slide)
# ns.bin=unique(ceiling(ns/slide))
if(n.select>50000)
{ns.bin=c(seq(0,90,10),seq(100,max(ns)/4,100),seq(max(ns)/4+150,max(ns)/3,150),seq(max(ns)/3+200,max(ns)/2,200),seq(max(ns)/2+300,max(ns),300))
}else{
ns.bin=seq(0,max(ns),5000)
}
loc=matrix(NA,length(ns.bin)-1,2)
j=0
for (i in 1:(length(ns.bin)-1)){
  j=j+1
  pieceD=maPure[ ns.bin[i]<ns&ns<ns.bin[i+1], 1]
  pieceR=maPure[ ns.bin[i]<ns&ns<ns.bin[i+1], 2]
  loc[i,1]=mean(pieceD,na.rm=T)
  loc[i,2]=mean(pieceR,na.rm=T)
}
lines(loc[,1]/Aver.Dis,loc[,2],col="darkred",xlim=c(0,WS0/Aver.Dis))

grDevices::dev.off()
colnames(loc)=c("Distance","Rsquare")
write.csv(loc,paste("GAPIT.Genotype.Distance.Rsquare.csv",sep=""))

grDevices::pdf("GAPIT.Genotype.Distance_R_Freq.pdf", width =10, height = 6)
par(mfcol=c(1,2),mar = c(5,5,2,2))

r0.hist=hist(r,  plot=FALSE)
r0=r0.hist$counts
r0.demo=ifelse(nchar(max(r0))<=4,1,ifelse(nchar(max(r0))<=8,1000,ifelse(nchar(max(r0))<=12,10000000,100000000000)))
r0.hist$counts=r0/r0.demo
ylab0=ifelse(nchar(max(r0))<=4,1,ifelse(nchar(max(r0))<=8,2,ifelse(nchar(max(r0))<=12,3,4)))
ylab.store=c("Frequency","Frequency (Thousands)","Frequency (Million)","Frequency (Billion)")
d.V.hist=hist(d.V, plot=FALSE)
d.V0=d.V.hist$counts
d.V0.demo=ifelse(nchar(max(d.V0))<=4,1,ifelse(nchar(max(d.V0))<=8,1000,ifelse(nchar(max(d.V0))<=12,10000000,100000000000)))
ylab0=ifelse(nchar(max(d.V0))<=4,1,ifelse(nchar(max(d.V0))<=8,2,ifelse(nchar(max(d.V0))<=12,3,4)))
ylab.store=c("Frequency","Frequency (Thousands)","Frequency (Million)","Frequency (Billion)")
d.V.hist$counts=d.V0/d.V0.demo
plot(r0.hist, xlab="R", las=1,ylab=ylab.store[ylab0], main="a",col="gray")

plot(d.V.hist, las=1,xlab="Distance (Kb)",col="gray", ylab=ylab.store[ylab0], main="b",cex=.5,xlim=c(0,WS0/Aver.Dis))

# hist(d.V0, las=1,xlab="Distance (Kb)", ylab="Frequency", main="e",cex=.5)

grDevices::dev.off()

H=1-abs(X2-1)
het.ind=apply(H,1,mean)
het.snp=apply(H,2,mean)

ss=apply(X2,2,sum)
maf=apply(cbind(.5*ss/(nrow(X2)),1-.5*ss/(nrow(X2))),1,min)
# theCol=array(0,m-1)
# for (i in 2:(m-1)){
#   if(myGI[i,2]==myGI[i-1,2])theCol[i]=theCol[i-1]
#   else theCol[i]=abs(theCol[i-1]-1)
# }


grDevices::pdf("GAPIT.Genotype.MAF_Heterozosity.pdf", width =10, height = 6)

#Display
layout.matrix <- matrix(c(1,2,3), nrow = 3, ncol = 1)
layout(mat = layout.matrix,
       heights = c(100,80,120), # Heights of the two rows
       widths = c(2, 3)) # Widths of the two columns
par(mar = c(1, 5, 1, 1))
plot(het.snp,  las=1,ylab="Heterozygosity", xlim=c(1,mm),axes=FALSE,
    cex=.5,col=colDisp,xaxt='n')
# axis(1,at=chr.pos,labels=rep("",length(chr)))
# axis(1,at=chr.pos[odd],labels=chr[odd],tick=FALSE)
axis(2,las=1)
par(mar = c(1, 5, 0, 1))
plot(maf, las=1,xlab="Marker", ylab="MAF",xlim=c(1,mm),axes=FALSE,
    cex=.5,col=colDisp,xaxt='n')
# axis(1,at=chr.pos,labels=rep("",length(chr)))
# axis(1,at=chr.pos[odd],labels=chr[odd],tick=FALSE)
axis(2,las=1)
par(mar = c(5, 5, 0, 1))
plot((r^2),  las=1,ylab="R Sqaure", xlab="Marker", xlim=c(1,mm),axes=FALSE,
    cex=.5,col=colDisp)
axis(1,at=chr.pos2,labels=rep("",length(chr)+1))
axis(1,at=chr.pos,labels=chr,tick=FALSE)
axis(2,las=1)
grDevices::dev.off()


#Display Het and MAF distribution
grDevices::pdf("GAPIT.Genotype.Frequency.pdf", width =10, height = 3.5)
layout.matrix <- matrix(c(1,2,3), nrow = 1, ncol = 3)
layout(mat = layout.matrix,
       heights = c(100,80,120), # Heights of the two rows
       widths = c(2, 2,2)) # Widths of the two columns
par(mar = c(5, 5, 2, 0))
hist(as.numeric(het.ind), las=1,xlab="Individual heterozygosity",freq=FALSE,ylab="Frequency", cex=.5,main="a")
par(mar = c(5, 4, 2, 1))
hist(het.snp, las=1,xlab="Marker heterozygosity", freq=FALSE,ylab="Frequency",cex=.5,main="b")
par(mar = c(5, 4, 2, 1))
hist(maf,  las=1,ylab="Frequency", xlab="MAF",freq=FALSE, cex=.5,main="c")

grDevices::dev.off()


# ViewGenotype2<-GAPIT.LD.decay(
# GI=GI,
# X=X,
# WS0=WS0,
# ws=ws,
# max.num=length(chr),
# # fre.by=100,  ## set 
# # MAXfregment=NULL,
# # max.number=NULL,
# Aver.Dis=Aver.Dis
# )

print(paste("GAPIT.Genotype.View ", ". pdfs generate.","successfully!" ,sep = ""))

#GAPIT.Genotype.View
}
#=============================================================================================
