'use strict';

const gulp = require('gulp4');
const uglify = require('gulp-uglify');
const babel = require('gulp-babel');
const autoprefixer = require('gulp-autoprefixer');
const concat = require('gulp-concat');
const rename = require('gulp-rename');
const sass = require('gulp-sass');
const watch = require('gulp-watch');
const sourcemaps=require('gulp-sourcemaps');
const del = require('del');
const copy = require('copy');

let is_watching=false;

function sassTask() {
    return gulp.src('./scss/*.scss')
        .pipe(sourcemaps.init())
        .pipe(autoprefixer())
        .pipe(sass({outputStyle: 'compressed'}).on('error', sass.logError))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/css')).on('end',function () {
            if(is_watching)copyDest();
        });
}


function sassadminTask() {
    return gulp.src('./scss/admin/*.scss')
        .pipe(sourcemaps.init())
        .pipe(autoprefixer())
        .pipe(sass({outputStyle: 'compressed'}).on('error', sass.logError))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/admin/css')).on('end',function () {
            if(is_watching)copyDest();
        });
}


let basejs=['js/model/common.js', 'js/model/template.js', 'js/model/dialog.js', 'js/model/jquery.tag.js', 'js/model/datetime.init.js'];
let backsrces=basejs.concat(['js/model/map.js','js/backend.js']);
function backendTask() {
    return gulp.src(backsrces)
        .pipe(sourcemaps.init())
        .pipe(babel({
            presets: ['@babel/preset-env']
        }))
        .pipe(concat('backend.js'))
        .pipe(rename({ basename: 'app' }))
        .pipe(gulp.dest('./dest/admin/js/'))
        .pipe(uglify())
        .pipe(rename({ extname: '.min.js' }))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/admin/js/')).on('end',function () {
            if(is_watching)copyDest();
        });
}

let labelsrces=['js/model/common.js', 'js/model/template.js', 'js/dialog.js']
function labelTask() {
    return gulp.src(labelsrces)
        .pipe(sourcemaps.init())
        .pipe(babel({
            presets: ['@babel/preset-env']
        }))
        .pipe(concat('label.js'))
        .pipe(rename({ basename: 'label' }))
        .pipe(gulp.dest('./dest/admin/js/'))
        .pipe(uglify())
        .pipe(rename({ extname: '.min.js' }))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/admin/js/')).on('end',function () {
            if(is_watching)copyDest();
        });
}


let frontsrces=basejs.concat(['js/front.js']);
function frontTask() {
    return gulp.src(frontsrces)
        .pipe(sourcemaps.init())
        .pipe(babel({
            presets: ['@babel/preset-env']
        }))
        .pipe(concat('front.js'))
        .pipe(rename({ basename: 'init' }))
        .pipe(gulp.dest('./dest/js/'))
        .pipe(uglify())
        .pipe(rename({ extname: '.min.js' }))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/js/')).on('end',function () {
            if(is_watching)copyDest();
        });
}


function mobileTask() {
    return gulp.src(['js/mobile.js'])
        .pipe(sourcemaps.init())
        .pipe(babel({
            presets: ['@babel/preset-env']
        }))
        .pipe(gulp.dest('./dest/js/'))
        .pipe(uglify())
        .pipe(rename({ extname: '.min.js' }))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/js/')).on('end',function () {
            if(is_watching)copyDest();
        });
}


function locationTask() {
    return gulp.src(['js/model/areas.js','js/model/location.js'])
        .pipe(sourcemaps.init())
        .pipe(concat('location.js'))
        .pipe(gulp.dest('./dest/js/'))
        .pipe(uglify())
        .pipe(rename({ extname: '.min.js' }))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest('./dest/js/')).on('end',function () {
            if(is_watching)copyDest();
        });
}


function clean(done) {
    del('dest/**/*').then(function(paths) {
        if(paths && paths.length) {
            console.log('Deleted files and folders:\n', paths.join('\n'));
        }else{
            console.log('No files were deleted.');
        }
        done()
    });
}

function copyDest(done) {
    console.log('Copy dest to public...');
    copy(['dest/**/*.css','dest/**/*.min.js','dest/**/*.min.js.map'],'../src/htdocs/static/',function () {
        if(done)done()
    });
}
function watchAll(done) {
    is_watching=true;
    console.log('Starting watch all files...');
    /* gulp.watch(['./scss/*.scss','./scss/model/*.scss'],sassTask, (event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    }); */
    gulp.watch(['./scss/admin/*.scss'],sassadminTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    gulp.watch(backsrces,backendTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    gulp.watch(labelsrces,labelTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    /* gulp.watch(frontsrces,frontTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    gulp.watch(['js/mobile.js'],mobileTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    }); */
    gulp.watch(['js/model/areas.js','js/model/location.js'],locationTask,(event)=> {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    if(done)done();
}

const build = gulp.series(clean,gulp.parallel(sassadminTask,backendTask,labelTask,locationTask), copyDest);
gulp.task('default', gulp.series(build, watchAll));
gulp.task('clean', clean);
gulp.task('watch', watchAll);

