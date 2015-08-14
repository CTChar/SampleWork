package vtc.edu.cis2730.blueprint;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.TextView;

@SuppressLint("WrongCall")
public class BluePrint extends View
{

	public BluePrint(int width, int length, int floors, Context context)
	{
		super(context);
		_width = width;
		_length = length;
		_floors = floors;
		_scale = 0.5;
		_floorLine = new TextView(context);
		_currentFloor = 1;
	}
	
	public BluePrint(int width, int length, int floors, Context context, int scale)
	{
		super(context);
		new BluePrint(width, length, floors, context);
		_scale = scale;
	}
	
	public void onDraw(Canvas canvas)
	{
		_canvas = canvas;
		_paint.setColor(Color.WHITE);
		_paint.setStrokeWidth(3);
        canvas.drawRect(50, 50, 50+_length, 50+_width, _paint);
        _paint.setColor(0xff003366);
        canvas.drawRect(53, 53, 47+_length, 47+_width, _paint);
	}
	
	public void switchFloor(int floorNum, FrameLayout frame)
	{
		frame.removeView(_floorLine);
		FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(20, 20);
		params.width = 200;
		if(floorNum <= 3)
		{
			onDraw(_canvas);
			switch(floorNum)
			{
				case 1:
					_floorLine.setText("Floor Number One");
					_currentFloor = 1;
					break;
				case 2:
					_floorLine.setText("Floor Number Two");
					_currentFloor = 2;
					break;
				case 3:
					_floorLine.setText("Floor Number Three");
					_currentFloor = 3;
					break;
			}
			frame.addView(_floorLine, params);
			_floorLine.setTextColor(0xffffffff);
		}
	}
	
	public void buildFloor()
	{
		
	}
	
	public boolean isInit()
	{
		if(_floors >=1 && _width >=1 && _length >=1)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	private TextView _floorLine;
	private int _floors;
	private int _width;
	private int _length;
	private double _scale;
	private Canvas _canvas;
	private int _currentFloor;
	ArrayList<FloorItem> _floorOne;
	ArrayList<FloorItem> _floorTwo;
	ArrayList<FloorItem> _floorThree;
	private Paint _paint = new Paint();
}