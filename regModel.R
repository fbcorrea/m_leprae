require(Biostrings)

#setwd("~/Dropbox/mestrado/disciplinas/algoritmos/Calc_R")
seqs <- readDNAStringSet("myco_silva.fas")


pdf('leprae.pdf', width=10, height=14)
par(mfrow = c(3,2))


for(j in 1:6){
	seqs_myco <- seqs[c(j,7:4946),]
	freqs <- oligonucleotideFrequency(seqs_myco, 6, step=1, as.prob=FALSE, as.array=FALSE, fast.moving.side="right", with.labels=TRUE, simplify.as="matrix")

	p1 <- 0.9999
	p0 <- 0.0001
	lch1 <- log(p1/(1-p1))
	lch0 <- log(p0/(1-p0))

	b <- rep(1,4941)*lch0
	b[1] = lch1
	B <- cbind(freqs, (rep(1,4941)))

	alfa <- solve((diag(4097) + t(B) %*% B), (t(B) %*% b))
	#plot(alfa, ylim =c(-1,1), pch=20, cex=.5)
	### MODEL END ###


	### QUERY
	max <- 50
	query <- subseq(seqs_myco[1], start=1, width=50)
	for (i in 2:1450){
	  query <- c(query, subseq(seqs_myco[1], start=i, width=50))
	}
	query_freqs <- oligonucleotideFrequency(query, 6, step=1, as.prob=FALSE, as.array=FALSE, fast.moving.side="right", with.labels=TRUE, simplify.as="matrix")

	# query <- as.matrix(freqs[1:12,])
	size <- nrow(query_freqs)
	Bq <- cbind (query_freqs, rep(1, size))
	v <- c(Bq %*% alfa)
	#v <- Bq * alfa
	num <- exp(v)
	p <- num/(1+num)
	

	name <- unlist(strsplit(names(seqs_myco[1])," ",))[1]

	plot(p, ylim=c(0,1), pch=20, cex=.3, xaxt="n", yaxt="n", xlab="Posição Inicial do Fragmento de Tamanho 100", ylab="Probabilidade", main=name)
	axis(1, at = seq(0, 1500, by = 200), las=2)
	axis(2, at = seq(0, 1, by = 0.1), las=2)
	rect(xleft=69, xright=99, ybottom=0, ytop=1, col ="red", density = 0) #V1
	text(mean(c(69,99)),1.02,'V1')
	rect(xleft=137, xright=242, ybottom=0, ytop=1, col ="red", density = 0) #V2
	text(mean(c(137,242)),1.02,'V2')
	rect(xleft=433, xright=497, ybottom=0, ytop=1, col ="red", density = 0) #V3
	text(mean(c(433,497)),1.02,'V3')
	rect(xleft=576, xright=682, ybottom=0, ytop=1, col ="red", density = 0) #V4
	text(mean(c(576,682)),1.02,'V4')
	rect(xleft=822, xright=879, ybottom=0, ytop=1, col ="red", density = 0) #V5
	text(mean(c(822,879)),1.02,'V5')
	rect(xleft=986, xright=1043, ybottom=0, ytop=1, col ="red", density = 0) #V6
	text(mean(c(986,1043)),1.02,'V6')
	rect(xleft=1117, xright=1173, ybottom=0, ytop=1, col ="red", density = 0) #V7
	text(mean(c(1117,1173)),1.02,'V7')
	rect(xleft=1243, xright=1294, ybottom=0, ytop=1, col ="red", density = 0) #V8
	text(mean(c(1243,1294)),1.02,'V8')
	rect(xleft=1435, xright=1465, ybottom=0, ytop=1, col ="red", density = 0) #V9
	text(mean(c(1435,1465)),1.02,'V9')
	abline(h=0.95)
}
dev.off()
