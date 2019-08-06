#!/bin/bash
vid=( ".mkv" ".mp4" ".avi" ".webm" )
pic=( ".bmp" ".gif" ".jpeg" ".jpg" ".png" ".svg" )
arc=( ".zip" ".tar" ".rar" ".7z" )

place="$HOME/Downloads"
IFS=$'\t\n'

video() {
	target="$HOME/Downloads/videos"
	[[ ! -d $target ]] && mkdir $target
			
	for i in ${!vid[*]}; do
	if ls "$place" | grep -i ${vid[i]} >/dev/null; then
		name=($(find $place -maxdepth 1 -type f \( -iname \*${vid[i]} \)))
		for i in ${!name[*]}; do
			mv -i ${name[i]} $target
		done
	fi
	done
}

picture() {
	target="$HOME/Downloads/pictures"
	[[ ! -d $target ]] && mkdir $target
		
	for i in ${!pic[*]}; do
		if ls "$place" | grep -i ${pic[i]} >/dev/null; then
			name=($(find $place -maxdepth 1 -type f \( -iname \*${pic[i]} \)))
			ext=${pic[i]}		
			for i in ${!name[*]}; do
				hash=$(md5sum ${name[i]} | awk '{print $1}')
				if [ $ext == ".gif" ];then
					[[ ! -d $target/gif ]] && mkdir $target/gif
					mv ${name[i]} $target/gif/$hash$ext
				elif [ $ext == ".jpeg" ] || [ $ext == ".jpg" ];then
					convert ${name[i]} $target/$hash.png && rm ${name[i]}
				elif [ $ext == ".png" ];then
					mv -i ${name[i]} $target/$hash$ext
				else		
					[[ ! -d $target/other ]] && mkdir $target/other
					mv -i ${name[i]} $target/other/$hash$ext
				fi
			done
		fi
	done
}

archive() {
	target="$HOME/Downloads/archives"
	[[ ! -d $target ]] && mkdir $target
	
	for i in ${!arc[*]}; do
		if ls "$place" | grep -i ${arc[i]} >/dev/null; then
			name=($(find $place -maxdepth 1 -type f \( -iname \*${arc[i]} \)))
			for i in ${!name[*]}; do
				mv -i ${name[i]} $target
			done
		fi
	done
}

etc() {
	target="$HOME/Downloads/other"
	[[ ! -d $target ]] && mkdir $target

	name=($(find $place -maxdepth 1 -type f))
	for i in ${!name[*]}; do
		mv ${name[i]} $target
	done
	dir=($(find $place/* -maxdepth 0 -type d \( -path $place/videos* -o -path $place/pictures* \
		-o -path $place/archives* -o -path $place/other* \) -prune -o -print))
	for i in ${!dir[*]}; do
		[[ ! -d $target/folders ]] && mkdir $target/folders
		if echo "${dir[i]}" | grep "1080p\|720p\|WEBRip" >/dev/null
		then mv -i ${dir[i]} $HOME/Downloads/videos;
		else mv -i ${dir[i]} $target/folders;
		fi
	done
}

video; picture; archive; etc;

