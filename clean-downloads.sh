#!/bin/bash
vid=( ".mkv" ".mp4" ".avi" ".webm" ".mov" )
pic=( ".bmp" ".gif" ".jpeg" ".jpg" ".png" ".svg" )
arc=( ".zip" ".tar" ".rar" ".7z" )

source_dir="$HOME/Downloads"  # Source directory
[[ -d $source_dir ]] || exit 1

IFS=$'\t\n'             # Don't count whitespace as a word boundary
shopt -s extglob        # Use extended globbing
shopt -s nocasematch    # Don't match case

# Write list of files including depth 1 subdirectories
# to a variable excluding target sort directories

get_list() {
	for f in "$source_dir"/*; do
		if [[ -d "$f" ]]; then
			for sdl in "$f"/*; do
				[[ $sdl = $source_dir/*(videos|pictures|archives|other)/* ]] && continue
				f_list+=("$sdl")
			done
		else
			f_list+=("$f")
		fi
	done
}

# Seperate files by extension
# Only video checks sub-folder for content
# Images are renamed to their md5 checksums

sort_chks() {
	[[ ".${f_name##*.}" = "$1" ]] || return 1
	[[ -d "$source_dir/$2" ]] || mkdir "$source_dir/$2"
}

run_sort() {
	get_list
	for fl in "${f_list[@]}"; do
		f_name=${fl##$source_dir/}

		# Sort Video Files
		for vf in "${vid[@]}"; do
			sort_chks "$vf" videos || continue
			if [[ $f_name = */* ]]; then
				[[ ${vid_list[*]} = *${fl%/*}* ]] && continue 2
				vid_list+=("${fl%/*}") && continue 2
			else
				vid_list+=("$fl") && continue 2
			fi
		done

		# Sort Image Files
		for pf in "${pic[@]}"; do
			sort_chks "$pf" pictures || continue
			[[ $f_name = */* ]] && continue
			[[ $(magick identify "$fl") ]] || continue
			[[ $pf = .jpg ]] && pf=".jpeg"
			[[ $(magick identify "$fl") != *" ${pf#.*} "* ]] && continue
			hashed_f_name=$(md5sum "$fl")

			# convert image to PNG and add to PNG list
			if [[ $pf = .jpeg ]]; then
				convert "$fl" "$fl.png" && rm "$fl"
				mv "$fl.png" "$source_dir/${hashed_f_name%% *}.png"
				png_list+=("$source_dir/${hashed_f_name%% *}.png") && continue 2
			fi

			# Seperate image types
			if [[ $pf = .png ]]; then
				mv "$fl" "$source_dir/${hashed_f_name%% *}$pf"
				png_list+=("$source_dir/${hashed_f_name%% *}$pf") && continue 2
			elif [[ $pf = .gif ]]; then
				[[ -d "$source_dir/pictures/gif" ]] || mkdir "$source_dir/pictures/gif"
				mv "$fl" "$source_dir/${hashed_f_name%% *}$pf"
				gif_list+=("$source_dir/${hashed_f_name%% *}$pf") && continue 2
			else
				[[ -d "$source_dir/pictures/other" ]] || mkdir "$source_dir/pictures/other"
				mv "$fl" "$source_dir/${hashed_f_name%% *}$pf"
				img_list+=("$source_dir/${hashed_f_name%% *}$pf") && continue 2
			fi
		done

		# Sort Archive Files
		for af in "${arc[@]}"; do
			sort_chks "$af" archives || continue
			[[ $f_name = */* ]] && continue
			arc_list+=("$fl") && continue 2
		done

		# Sort Misc Files
		[[ -d "$source_dir/other" ]] || mkdir "$source_dir/other"
		if [[ $f_name = */* ]]; then
			[[ -d "$source_dir/other/folders" ]] || mkdir "$source_dir/other/folders"

			# Attempt at catching missed videos
			if [[ $f_name = *(*1080p*|*720p*|*420p*|*WEBRip*) ]]; then
				[[ ${vid_list[*]} = *${fl%/*}* ]] && continue
				vid_list+=("${fl%/*}") && continue
			fi

			# Sort Misc Folders
			[[ ${vid_list[*]} = *${fl%/*}* ]] && continue
			[[ ${misc_dir_list[*]} = *${fl%/*}* ]] && continue
			misc_dir_list+=("${fl%/*}") && continue
		fi
		misc_list+=("$fl")
	done
}

# Run and move files
run_sort
[[ -n "${vid_list[*]}" ]] && mv -i "${vid_list[@]}" "$source_dir/videos"
[[ -n "${png_list[*]}" ]] && mv -i "${png_list[@]}" "$source_dir/pictures"
[[ -n "${gif_list[*]}" ]] && mv -i "${gif_list[@]}" "$source_dir/pictures/gif"
[[ -n "${img_list[*]}" ]] && mv -i "${img_list[@]}" "$source_dir/pictures/other"
[[ -n "${arc_list[*]}" ]] && mv -i "${arc_list[@]}" "$source_dir/archives"
[[ -n "${misc_list[*]}" ]] && mv -i "${misc_list[@]}" "$source_dir/other"
[[ -n "${misc_dir_list[*]}" ]] && mv -i "${misc_dir_list[@]}" "$source_dir/other/folders"
exit 0

